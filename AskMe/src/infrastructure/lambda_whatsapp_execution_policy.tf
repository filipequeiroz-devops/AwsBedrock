# Lambda identity
resource "aws_iam_role" "lambda_exec_role_whatsapp" {
  name = "lambda_exec_role_whatsapp"

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

resource "aws_iam_role_policy" "lambda_exec_policy_whatsapp" {
  name = "lambda_exec_policy_whatsapp"
  role = aws_iam_role.lambda_exec_role_whatsapp.id

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
      # Permission for lambda public to call lambda private
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.lambda_aurora.arn
      }
    ]
  })
}