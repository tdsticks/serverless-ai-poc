resource "aws_api_gateway_rest_api" "serverless_ai_api" {
  name        = "serverless-ai-api"
  description = "API Gateway for Serverless AI Lambda"

  tags = {
    Name        = "serverless-ai-api"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_api_gateway_resource" "api_root" {
  rest_api_id = aws_api_gateway_rest_api.serverless_ai_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_ai_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.serverless_ai_api.id
  parent_id   = aws_api_gateway_resource.api_root.id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "api_get" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_ai_api.id
  resource_id   = aws_api_gateway_resource.api_root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_ai_api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.serverless_ai_api.id
  resource_id = aws_api_gateway_resource.api_root.id
  http_method = aws_api_gateway_method.api_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.serverless_ai_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "hello_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.serverless_ai_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.serverless_ai_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "serverless_ai_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.api_get_integration,
    aws_api_gateway_integration.hello_get_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.serverless_ai_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.api_get.id,
      aws_api_gateway_method.hello_get.id,
      aws_api_gateway_integration.api_get_integration.id,
      aws_api_gateway_integration.hello_get_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "serverless_ai_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_ai_api.id
  deployment_id = aws_api_gateway_deployment.serverless_ai_api_deployment.id
  stage_name    = "dev"

  tags = {
    Name        = "serverless-ai-api-stage"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_ai_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.serverless_ai_api.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.serverless_ai_api_stage.invoke_url
}
