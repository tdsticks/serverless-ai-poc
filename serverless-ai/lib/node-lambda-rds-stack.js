const cdk = require('aws-cdk-lib');
const lambda = require('aws-cdk-lib/aws-lambda');
const apigateway = require('aws-cdk-lib/aws-apigateway');
const rds = require('aws-cdk-lib/aws-rds');
const ec2 = require('aws-cdk-lib/aws-ec2');
const secretsmanager = require('aws-cdk-lib/aws-secretsmanager');
require('dotenv').config();

class NodeLambdaRdsStack extends cdk.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a VPC (required for RDS)
    // const vpc = new ec2.Vpc(this, 'MyVpc', { maxAzs: 2 });
    const vpc = new ec2.Vpc(this, 'MyVpc', {
        maxAzs: 2,  // Limits to 2 Availability Zones
        natGateways: 1,  // Use only 1 NAT Gateway instead of 2+
        subnetConfiguration: [
          {
            cidrMask: 24,
            name: 'PublicSubnet',
            subnetType: ec2.SubnetType.PUBLIC,  // Only create Public Subnets
          },
          {
            cidrMask: 24,
            name: 'PrivateSubnet',
            subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,  // Only create Private Subnets
          }
        ],
      });

    // Create an RDS Postgres instance
    const dbSecret = new secretsmanager.Secret(this, 'DBSecret', {
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: 'postgres' }),
        excludePunctuation: true,
        includeSpace: false,
        generateStringKey: 'password',
      },
    });

    const dbInstance = new rds.DatabaseInstance(this, 'PostgresDB', {
      engine: rds.DatabaseInstanceEngine.postgres({ version: rds.PostgresEngineVersion.VER_16_6 }),
      vpc,
      credentials: rds.Credentials.fromSecret(dbSecret),
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE3, ec2.InstanceSize.MICRO),
      allocatedStorage: 20,
      databaseName: process.env.DB_NAME,
    });

    // Create the Lambda function
    const lambdaFunction = new lambda.Function(this, 'LambdaFunction', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('lambda'),
      environment: {
        DB_HOST: dbInstance.dbInstanceEndpointAddress,
        // DB_HOST: process.env.DB_HOST,
        DB_USER: process.env.DB_USER,
        DB_PASSWORD: process.env.DB_PASSWORD,
        DB_NAME: process.env.DB_NAME,
        DB_PORT: process.env.DB_PORT || '5432',
      },
      vpc, // Attach Lambda to VPC to allow RDS connection
    });

    // Create API Gateway and integrate with Lambda
    const api = new apigateway.LambdaRestApi(this, 'ApiGateway', {
      handler: lambdaFunction,
      proxy: true, // Route all requests to Lambda
    });

    // Output API URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
    });

    // Allow Lambda to access RDS
    dbInstance.connections.allowFrom(lambdaFunction, ec2.Port.tcp(5432), 'Allow Lambda to connect to RDS');
  }
}

module.exports = { NodeLambdaRdsStack };
