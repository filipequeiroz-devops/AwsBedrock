resource "aws_bedrockagent_knowledge_base" "barber_kb" {
  name     = "${var.company_name}-kb"
  role_arn = aws_iam_role.bedrock_kb_role.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
    }
  }

  storage_configuration {
    type = "RDS"
    rds_configuration {
      resource_arn           = aws_rds_cluster.vector_db.arn
      credentials_secret_arn = aws_ssm_parameter.db_password.arn # Aqui usamos o SSM que você criou

      field_mapping {
        vector_field      = "embedding"
        text_field        = "chunks"
        primary_key_field = "id"
        metadata_field    = "metadata"
      }

    endpoint_configuration {
        type = "VPC" # Defines access by private networkd
        vpc_configuration {
          subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
          security_group_ids = [aws_security_group.bedrock_sg.id]
        }
      }

      database_name = "barberdb"
      table_name    = "vectors"
    }
  }
}

#bedrock connector
resource "aws_bedrockagent_data_source" "barber_ds" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.barber_kb.id
  name              = "${var.company_name}-s3-source"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledge_base.arn
    }
  }
}