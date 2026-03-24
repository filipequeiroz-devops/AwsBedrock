#private network
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.company_name}-vpc"
  }
}

#aurora needs at least 2 subnets in different availability zones
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.company_name}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.company_name}-private-subnet-2"
  }
}

#Security Groups
resource "aws_security_group" "rds_sg" {

  name        = "${var.company_name}-rds-sg"
  description = "Allow access to RDS Aurora"
  vpc_id      = aws_vpc.main.id


  #inbound rules
  ingress {
    from_port   = 5432 # default port for PostgreSQL
    to_port     = 5432 # max port range
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # allow access from within the VPC

  }

  # Outbound rules
  # Nothing 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "aurora_group" {
  name        = "${var.company_name}-db-subnet-group"
  description = "subnetgroups for database ${var.company_name}"

  #Subnets I just created above  
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "${var.company_name}-db-subnet-group"
  }
}

#VPC endpoint for bedrock
resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.bedrock-runtime"
  vpc_endpoint_type = "Interface"

  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  security_group_ids = [aws_security_group.rds_sg.id] #

  private_dns_enabled = true
}