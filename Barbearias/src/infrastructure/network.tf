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

#Security Groups - RDS aurora
resource "aws_security_group" "rds_sg" {

  name        = "${var.company_name}-rds-sg"
  description = "Allow access to RDS Aurora and bedrock"
  vpc_id      = aws_vpc.main.id


  # default port for PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # allow access from within the VPC

  }

  # default port for Bedrock (HTTPS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
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

#Security Groups - lambda
resource "aws_security_group" "lambda_sg" {

  name        = "${var.company_name}-lambda-sg"
  description = "Allow access to RDS Aurora and bedrock"
  vpc_id      = aws_vpc.main.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security Groups - Bedrock
resource "aws_security_group" "bedrock_sg" {

  name        = "${var.company_name}-bedrock-sg"
  description = "Allow bedrock do access rds aurora"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.company_name}-private-rt"
  }
}

# Route tables assocition with private subnets
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

#subnet groups for aurora
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

## VPC endpoint for bedrock
#resource "aws_vpc_endpoint" "bedrock_runtime" {
#  vpc_id            = aws_vpc.main.id
#  service_name      = "com.amazonaws.us-east-1.bedrock-runtime"
#  vpc_endpoint_type = "Interface"
#
#  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
#  security_group_ids = [aws_security_group.rds_sg.id] #
#
#  private_dns_enabled = true
#
#  tags = {
#    Name = "${var.company_name}-bedrock-endpoint"
#  }
#}

# VPC endpoint for dynamodb
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id] #associates endpoint with the private tables

  tags = {
    Name = "${var.company_name}-dynamodb-endpoint"
  }

}