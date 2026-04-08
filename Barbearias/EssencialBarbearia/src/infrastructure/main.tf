terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "saopaulo"
  region = "sa-east-1"
}

module "minha_infra_barbearia" {

  #variables from chatbot_core/variables.tf
  source                       = "../../../../chatbot_core"
  company_name                 = "essencialbarbearia" 
  lambda_whatsapp_handler_path = "${path.module}/handlers/lambda_whatsapp"
  lambda_aurora_handler_path   = "${path.module}/handlers/lambda_aurora"
  docs_path                    = "${path.module}/docs"
  db_password                  = var.db_password
  verify_token                 = var.verify_token
  whatsapp_token               = var.whatsapp_token
  phone_number_id              = var.phone_number_id
  companys_phone               = var.companys_phone
  companys_phone2              = var.companys_phone2
  system_prompt_path           = "${path.module}/system_prompt.txt"
}