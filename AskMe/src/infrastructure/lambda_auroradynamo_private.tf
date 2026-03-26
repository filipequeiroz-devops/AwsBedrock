#This is the lambda that will speak with rds aurora, which is a Private subnet
data "archive_file" "aurora_zip" {
  type        = "zip"
  source_dir  = "${path.module}/handlers/lambda_aurora"
  output_path = "${path.module}/handlers/lambda_aurora_payload.zip"
}

resource "aws_lambda_function" "lambda_aurora" {
  filename      = data.archive_file.aurora_zip.output_path
  function_name = "lambda_aurora"
  role          = aws_iam_role.lambda_exec_role_auroradynamo.arn #execution role from lambda_execution_policy_bedrock.tf
  handler       = "bedrockcode.lambda_handler"                   # inside zip file, search for o confirm_handler.py
  runtime       = "python3.11"

  source_code_hash = data.archive_file.aurora_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    #VARIABLES TO BE CREATED
    #variables = {
    #VARIABLE_NAME = "value"
    #}
  }


}

resource "aws_lambda_permission" "apigw_lambdaaurora_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_aurora.function_name
  principal     = "apigateway.amazonaws.com"
}