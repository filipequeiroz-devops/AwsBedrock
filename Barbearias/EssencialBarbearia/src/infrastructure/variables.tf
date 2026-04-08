variable "db_password" {
  type        = string
  description = "Password for the database"
}

variable "verify_token" {
  type        = string
  description = "Token used to verify the webhook with WhatsApp"
}

variable "phone_number_id" {
  type        = string
  description = "ID of the phone number registered in WhatsApp Business API"
}

variable "whatsapp_token" {
  type        = string
  description = "Token used to authenticate with WhatsApp API"
}

variable "companys_phone" {
  type        = string
  description = "Número de telefone da empresa, necessário para o prompt do sistema"
}

variable "companys_phone2" {
  type        = string
  description = "Número de telefone da empresa, necessário para o prompt do sistema"
}