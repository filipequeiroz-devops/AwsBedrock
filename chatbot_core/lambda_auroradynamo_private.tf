#This is the lambda that will speak with rds aurora, which is a Private subnet
data "archive_file" "aurora_zip" {
  type        = "zip"
  source_dir  = var.caminho_lambda_aurora_handler_path
  output_path = "${path.module}/.terraform/lambda_whatsapp_payload.zip"
}

resource "aws_lambda_function" "lambda_aurora" {
  filename      = data.archive_file.aurora_zip.output_path
  function_name = "lambda_aurora"
  role          = aws_iam_role.lambda_exec_role_auroradynamo.arn #execution role from lambda_execution_policy_bedrock.tf
  handler       = "bedrockcode.lambda_handler"                   # inside zip file, search for o confirm_handler.py
  runtime       = "python3.11"
  timeout       = 60 #necessary because the lambda will call bedrock and wait for the response, which can take some time depending on the model and the size of the response
  memory_size   = 512
  source_code_hash = data.archive_file.aurora_zip.output_base64sha256

  #vpc_config {
  #  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  #  security_group_ids = [aws_security_group.lambda_sg.id]
  #}

  environment {
    variables = {
    WHATSAPP_TOKEN              = var.whatsapp_token
    PHONE_NUMBER_ID             = var.phone_number_id
    KNOWLEDGE_BASE_ID           = aws_bedrockagent_knowledge_base.barber_kb.id
    MODEL_ARN                   = var.model_arn
    SYSTEM_PROMPT               = local.system_prompt
    DYNAMODB_TABLE              = aws_dynamodb_table.users_table.name
    DYNAMODB_APPOINTMENTS_TABLE = aws_dynamodb_table.appointments_table.name
    COMPANYS_PHONE              = var.companys_phone
    COMPANYS_PHONE2             = var.companys_phone2
    }
  }


}

resource "aws_lambda_permission" "apigw_lambdaaurora_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_aurora.function_name
  principal     = "apigateway.amazonaws.com"
}