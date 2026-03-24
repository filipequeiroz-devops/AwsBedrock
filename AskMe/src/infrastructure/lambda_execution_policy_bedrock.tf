# Lambda identity
resource "aws_iam_role" "lambda_exec_role_bedrock" {
  name = "lambda_exec_role_bedrock"

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

resource "aws_iam_role_policy" "lambda_exec_policy_bedrock" {
  name = "lambda_exec_policy_bedrock"
  role = aws_iam_role.lambda_exec_role_bedrock.id

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
          "dynamodb:Updateitem", #to update the conversation
          "dynamodb:Query"       #to query the conversation
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.users_table.arn
      },

      # Permission for lambda public to call lambda private
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.lambda_aurora.arn
      }
    ]
  })
}