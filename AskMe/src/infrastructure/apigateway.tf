resource "aws_apigatewayv2_api" "bedrock_api" {
    name          = "barber-api"
    protocol_type = "HTTP"

     cors_configuration {
        allow_credentials = false
        allow_headers     = [
            "authorization",
            "content-type",
        ]
        allow_methods     = [
            "GET",
            "OPTIONS",
            "POST",
            "PUT",
            "DELETE",
        ]
        allow_origins     = [
            "*",
        ]
        expose_headers    = []
        max_age           = 0
    }
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.bedrock_api.id
  name        = "production" #I did not creates any test stage, so I will use production as default
  auto_deploy = true
}

#Integrates API with lambda funcion that will process the signup request
resource "aws_apigatewayv2_integration" "lambda_bedrock_integration_" {
  api_id           = aws_apigatewayv2_api.bedrock_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.lambda_bedrock.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda_bedrock_route_post" {
  api_id    = aws_apigatewayv2_api.bedrock_api.id
  route_key = "POST /bedrock" #defines the routes and methods that will trigger the lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_bedrock_integration_.id}"
}

resource "aws_apigatewayv2_route" "lambda_bedrock_route_get" {
  api_id    = aws_apigatewayv2_api.bedrock_api.id
  route_key = "GET /bedrock" #defines the routes and methods that will trigger the lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_bedrock_integration_.id}"
}

resource "aws_apigatewayv2_route" "lambda_bedrock_route_put" {
  api_id    = aws_apigatewayv2_api.bedrock_api.id
  route_key = "PUT /bedrock" #defines the routes and methods that will trigger the lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_bedrock_integration_.id}"
}

resource "aws_apigatewayv2_route" "lambda_bedrock_route_delete" {
  api_id    = aws_apigatewayv2_api.bedrock_api.id
  route_key = "DELETE /bedrock" #defines the routes and methods that will trigger the lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_bedrock_integration_.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_bedrock.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.bedrock_api.execution_arn}/*/*" #defining taht only this api gateway can invoke the lambda function, all stages and methods are allowed
}