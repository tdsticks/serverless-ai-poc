# Lambda IAM Role
resource "aws_iam_role" "serverless_ai_lambda_role" {
  name = "serverless-ai-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Basic Lambda Execution Policy (CloudWatch Logs, Required)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.serverless_ai_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda VPC Access Policy (ENI Permissions)
resource "aws_iam_policy" "lambda_vpc_access" {
  name        = "serverless-ai-lambda-vpc-access-policy"
  description = "Allows Lambda to create network interfaces in a VPC"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      Resource = "*"
    }]
  })
}

# Attach the VPC Access Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.serverless_ai_lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
}

# Lambda Function
resource "aws_lambda_function" "serverless_ai_lambda" {
  function_name = "serverless-ai-api"
  runtime       = "nodejs20.x"
  handler       = "app.main"
  role          = aws_iam_role.serverless_ai_lambda_role.arn
  filename      = "./lambda.zip"
  source_code_hash = filebase64sha256("./lambda.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_HOST     = var.db_host
      DB_NAME     = var.db_name
      DB_PORT     = var.db_port
      NODE_ENV    = var.environment
    }
  }
}
