resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.company_name}/db_password"
  type  = "SecureString"
  value = var.db_password
}