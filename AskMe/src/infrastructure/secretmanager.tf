# generating a password
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?" #choosing which special cachracter I want
}

# 2. Cria o "Cofre" no Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.company_name}-aurora-credentials"
  description = "Credenciais do PostgreSQL para o Data API e Bedrock"

  #allowing terraform to destroy it, so I can recreate it later 
  #If I don't set this value to 0, AWS will block terraform do destroy this resource for 30 days I will be force to create a resource with a differente name
  recovery_window_in_days = 0
}

# Saves the credential in json format, which will necessary for DATA API later
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "${var.company_name}dbadmin"
    password = random_password.db_password.result
  })
}