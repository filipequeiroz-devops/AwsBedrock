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