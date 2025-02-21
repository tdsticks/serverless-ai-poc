#!/usr/bin/env node
const cdk = require('aws-cdk-lib');
const { NodeLambdaRdsStack } = require('../lib/node-lambda-rds-stack');

const app = new cdk.App();
new NodeLambdaRdsStack(app, 'NodeLambdaRdsStack');
