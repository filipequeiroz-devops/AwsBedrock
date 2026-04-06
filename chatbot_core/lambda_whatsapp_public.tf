#This is the lambda that will speak with rds aurora, which is a Private subnet
data "archive_file" "whatsapp_zip" {
  type        = "zip"
  source_dir  = var.caminho_lambda_whatsapp_handler_path
  output_path = "${path.module}/.terraform/lambda_whatsapp_payload.zip"
}

resource "aws_lambda_function" "lambda_whatsapp" {
  filename      = data.archive_file.whatsapp_zip.output_path
  function_name = "lambda_whatsapp"
  role          = aws_iam_role.lambda_exec_role_whatsapp.arn #execution role from lambda_execution_policy_bedrock.tf
  handler       = "bedrockcode.lambda_handler"               # inside zip file, search for o confirm_handler.py
  runtime       = "python3.11"

  source_code_hash = data.archive_file.whatsapp_zip.output_base64sha256

  environment {
    #VARIABLES 
    variables = {
    PRIVATE_LAMBDA_NAME = aws_lambda_function.lambda_aurora.function_name
    VERIFY_TOKEN        = var.verify_token
    }
  }


}

resource "aws_lambda_permission" "apigw_lambdawhatsapp_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_whatsapp.function_name
  principal     = "apigateway.amazonaws.com"
}