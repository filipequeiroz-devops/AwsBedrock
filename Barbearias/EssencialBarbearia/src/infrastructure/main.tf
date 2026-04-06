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

  #variáveis para o módulo  que foram definidas na pasta chatbot_core/variables.tf
  source = "../../chatbot_core"
  company_name = "essencial-barbearia"
  caminho_lambda_whatsapp = "${path.module}/handlers/lambda_whatsapp"
  caminho_lambda_aurora   = "${path.module}/handlers/lambda_aurora"
  caminho_docs            = "${path.module}/docs"
}