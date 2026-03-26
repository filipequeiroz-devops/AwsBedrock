# 1. A Entidade de Confiança (Quem pode assumir essa Role)
resource "aws_iam_role" "bedrock_kb_role" {
  name = "${var.company_name}-bedrock-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
    }]
  })
}

# Permission, what bedrock can do
resource "aws_iam_role_policy" "bedrock_kb_policy" {
  name = "${var.company_name}-bedrock-kb-policy"
  role = aws_iam_role.bedrock_kb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # permission to use Embedding model (Titan)
      {
        Action   = "bedrock:InvokeModel"
        Effect   = "Allow"
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
      },

      #Permission to read s3
      {
        Action = ["s3:GetObject", "s3:ListBucket"]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.knowledge_base.arn,
          "${aws_s3_bucket.knowledge_base.arn}/*"
        ]
      },
      # Permission to access Auroro (via Query Editor/Data API ou acesso direto)
      {
        Action = [
          "rds-data:*",
          "rds:DescribeDBClusters"
        ]
        Effect   = "Allow"
        Resource = aws_rds_cluster.vector_db.arn
      },

      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}