# This Null resource will be used for allocating memory for running aws cli commands
# Terraform has no native ways to create a table in rds aurora via https on terraform apply
# I'm using AWS CLI for it
resource "null_resource" "init_vector_db" {
  triggers = {
    cluster_id = aws_rds_cluster.vector_db.id
  }

  # dependencies so I'll ensure terrform will run the sql script only when aurora is created
  depends_on = [
    aws_rds_cluster_instance.cluster_instance,
    aws_secretsmanager_secret_version.db_credentials_version
  ]

provisioner "local-exec" {
    command = <<EOT
      # Chamada 1: Cria a extensão vector
      aws rds-data execute-statement `
        --resource-arn ${aws_rds_cluster.vector_db.arn} `
        --secret-arn ${aws_secretsmanager_secret.db_credentials.arn} `
        --database "${var.company_name}db" `
        --sql "CREATE EXTENSION IF NOT EXISTS vector;" `
        --region us-east-1

      # Chamada 2: Cria a tabela
      aws rds-data execute-statement `
        --resource-arn ${aws_rds_cluster.vector_db.arn} `
        --secret-arn ${aws_secretsmanager_secret.db_credentials.arn} `
        --database "${var.company_name}db" `
        --sql "CREATE TABLE IF NOT EXISTS vectors (id UUID PRIMARY KEY, embedding vector(1536), chunks TEXT, metadata JSON);" `
        --region us-east-1

      # Chamada 3: Cria o índice GIN (Texto)
      aws rds-data execute-statement `
        --resource-arn ${aws_rds_cluster.vector_db.arn} `
        --secret-arn ${aws_secretsmanager_secret.db_credentials.arn} `
        --database "${var.company_name}db" `
        --sql "CREATE INDEX IF NOT EXISTS chunks_idx ON vectors USING gin (to_tsvector('simple', chunks));" `
        --region us-east-1

      # Chamada 4: Cria o índice HNSW (Vetores/IA) 
      aws rds-data execute-statement `
        --resource-arn ${aws_rds_cluster.vector_db.arn} `
        --secret-arn ${aws_secretsmanager_secret.db_credentials.arn} `
        --database "${var.company_name}db" `
        --sql "CREATE INDEX IF NOT EXISTS embedding_idx ON vectors USING hnsw (embedding vector_cosine_ops);" `
        --region us-east-1
    EOT

    interpreter = ["PowerShell", "-Command"]
  }
}