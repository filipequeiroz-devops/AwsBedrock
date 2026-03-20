# Lambda identity - Who qualifies to assume this role and execute the Lambda function !
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

# Lambda permissions - What actions the Lambda function can perform and on which resources
resource "aws_iam_role_policy" "lambda_exec_policy_bedrock" {
  name = "lambda_exec_policy_bedrock"
  role = aws_iam_role.lambda_exec_role_bedrock.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #allow logging to CloudWatch
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}