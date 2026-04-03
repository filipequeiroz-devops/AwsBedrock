output "api_gateway_url" {
  value = aws_apigatewayv2_api.bedrock_api.api_endpoint
  description = "URL do API Gateway para acessar a API"
}