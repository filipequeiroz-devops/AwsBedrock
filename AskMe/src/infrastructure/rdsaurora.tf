resource "aws_rds_cluster" "vector_db" {
  cluster_identifier     = "${var.company_name}-vector-db"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned" # needed for Serverless v2
  engine_version         = "16.1"        # version that supports pgvector
  database_name          = "${var.company_name}db"
  master_username        = "admin"
  master_password        = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.aurora_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Data API
  enable_http_endpoint   = true

  serverlessv2_scaling_configuration {
    max_capacity = 2.0
    min_capacity = 0.5 # Least possible cost
  }
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  cluster_identifier = aws_rds_cluster.vector_db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.vector_db.engine
  engine_version     = aws_rds_cluster.vector_db.engine_version
}