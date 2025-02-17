resource "aws_iam_role" "serverless_ai_lambda_role" {
  name = "serverless-ai-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
    }]
  })

  tags = {
    Name        = "serverless-ai-lambda-role"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_iam_policy_attachment" "serverless_ai_lambda_basic_execution" {
  name       = "serverless-ai-lambda-basic-execution"
  roles      = [aws_iam_role.serverless_ai_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "serverless_ai_lambda_vpc_access" {
  name = "serverless-ai-lambda-vpc-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "serverless-ai-lambda-vpc-access-policy"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_iam_role_policy_attachment" "serverless_ai_lambda_vpc_access_attach" {
  role       = aws_iam_role.serverless_ai_lambda_role.name
  policy_arn = aws_iam_policy.serverless_ai_lambda_vpc_access.arn
}

resource "aws_lambda_function" "serverless_ai_lambda" {
  function_name = "serverless-ai-api"
  runtime       = "nodejs20.x"
  handler       = "app.main"
  role          = aws_iam_role.serverless_ai_lambda_role.arn

  filename         = "./lambda.zip"
  source_code_hash = filebase64sha256("./lambda.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.serverless_ai_private_subnet_a.id, aws_subnet.serverless_ai_private_subnet_b.id]
    security_group_ids = [aws_security_group.serverless_ai_lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.serverless_ai_db.endpoint
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
      DB_PORT     = var.db_port
      NODE_ENV    = var.node_env
    }
  }

  tags = {
    Name        = "serverless-ai-lambda"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

variable "db_name" {}
variable "db_port" {}
variable "node_env" {}
