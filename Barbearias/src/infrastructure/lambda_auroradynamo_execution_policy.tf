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

data "aws_caller_identity" "current" {}

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
          "dynamodb:Query",      #to query the conversation history of a specific user (using the hash key UserId) 
          "dynamodb:Scan"        #to scan the appointments table and find pending appointments (using the hash key UserId and filter by Status = PENDENTE)
        ]
        Effect   = "Allow"
        Resource = [
          aws_dynamodb_table.users_table.arn,
          aws_dynamodb_table.appointments_table.arn
        ]
      },

      {
        Action = [
          "aws-marketplace:ViewSubscriptions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
      Action = [
        "bedrock:GetInferenceProfile"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:bedrock:us-east-1:307162859835:inference-profile/us.anthropic.claude-3-5-haiku-20241022-v1:0"
}
    ]
  })
}

#Since this lambda is private, needs vpc access
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec_role_auroradynamo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}