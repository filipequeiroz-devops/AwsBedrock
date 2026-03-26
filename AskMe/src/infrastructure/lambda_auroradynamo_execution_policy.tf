# Lambda identity
resource "aws_iam_role" "lambda_exec_role_auroradynamo" {
  name = "lambda_exec_role_auroradynamo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_exec_policy_auroradynamo" {
  name = "lambda_exec_policy_auroradynamo"
  role = aws_iam_role.lambda_exec_role_auroradynamo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #logs permissions
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },

      #Bedro permissions
      {
        Action = [
          "bedrock:InvokeModel",         # to call the LLM
          "bedrock:RetrieveAndGenerate", # Knowledge retrieval + generation in one step
          "bedrock:Retrieve"             # search in s3/opensearch
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      # DynamoDV permissions
      {
        Action = [
          "dynamodb:PutItem",    #to save the conversation
          "dynamodb:GetItem",    #to retrieve the conversation
          "dynamodb:UpdateItem", #to update the conversation
          "dynamodb:Query"       #to query the conversation
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.users_table.arn
      }
    ]
  })
}

#Since this lambda is private, needs vpc access
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec_role_auroradynamo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}