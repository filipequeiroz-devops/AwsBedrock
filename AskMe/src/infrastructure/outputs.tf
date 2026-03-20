output "api_gateway_url" {
  value = aws_apigatewayv2_api.bedrock_api.execution_arn
}