output "api_endpoint" {
  value = aws_apigatewayv2_api.serverless_ai_api.api_endpoint
}

output "vpc_id" {
  value = aws_vpc.serverless_ai.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_subnet_b.id
}