#lambda for validating user confirmation and login
data "archive_file" "bedrockcode_zip" {
  type        = "zip"
  source_dir  = "${path.module}/handlers/"
  output_path = "${path.module}/handlers/bedrockcode_payload.zip"
}

resource "aws_lambda_function" "lambda_bedrock" {
  filename      = data.archive_file.bedrockcode_zip.output_path
  function_name = "lambda_bedrock"
  role          = aws_iam_role.lambda_exec_role_bedrock.arn     #execution role from lambda_execution_policy_bedrock.tf
  handler       = "bedrockcode.lambda_handler"                  # inside zip file, search for o confirm_handler.py
  runtime       = "python3.11"

  source_code_hash = data.archive_file.bedrockcode_zip.output_base64sha256

  environment {
    #VARIABLES TO BE CREATED
    #variables = {
      #VARIABLE_NAME = "value"
    #}
  }
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_bedrock.function_name
  principal     = "apigateway.amazonaws.com"
}