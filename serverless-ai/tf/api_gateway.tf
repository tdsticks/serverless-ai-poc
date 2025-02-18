resource "aws_apigatewayv2_api" "serverless_ai_api" {
  name          = "serverless-ai-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.serverless_ai_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.serverless_ai_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.serverless_ai_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "index" {
  api_id    = aws_apigatewayv2_api.serverless_ai_api.id
  route_key = "GET /api"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.serverless_ai_api.id
  route_key = "GET /api/hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_ai_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.serverless_ai_api.execution_arn}/*/*"
}