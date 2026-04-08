variable "ami_id" {
  type        = string
  default     = "ami-02dfbd4ff395f2a1b"
  description = "AMI ID for the EC2 instances"
}

variable "key_name" {
  type        = string
  default     = "Wevy Key"
  description = "Name of the SSH key pair to access the EC2 instances"
}


variable "db_password" {
  type        = string
  description = "Password for the database"
}

variable "verify_token" {
  type        = string
  description = "Token used to verify the webhook with WhatsApp"
}

variable "whatsapp_token" {
  type        = string
  description = "Token used to authenticate with WhatsApp API"
}

variable "phone_number_id" {
  type        = string
  description = "ID of the phone number registered in WhatsApp Business API"
}

## O prompt do sistema (As regras de negócio do agente)
#variable "system_prompt" {
#  type        = string
#  description = "System prompt that defines the behavior of the virtual assistant"
#}

variable "model_arn" {
  type        = string
  default     = "arn:aws:bedrock:us-east-1:307162859835:inference-profile/us.anthropic.claude-3-5-haiku-20241022-v1:0"
  description = "ARN of the Bedrock embedding model to be used in the knowledge base"
}

variable "companys_phone" {
  type        = string
  description = "Número de telefone da empresa, necessário para o prompt do sistema"
}

variable "companys_phone2" {
  type        = string
  description = "Número de telefone da empresa, necessário para o prompt do sistema"
}

#varibles 
variable "company_name" { #lowercase, without spaces, no special characters, used for naming resources, best avoiding issues with naming conventions in AWS
  type    = string
}
variable "lambda_whatsapp_handler_path" {
  type    = string
}

variable "lambda_aurora_handler_path" {
  type    = string
}

variable "docs_path" {
  type    = string
}

variable "system_prompt_path" {
  type    = string
}

#locals {
#  system_prompt = file("${path.module}/system_prompt.txt")
#}