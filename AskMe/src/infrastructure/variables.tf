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

variable "company_name" {
  type    = string
  default = "barber"

}

variable "db_password" {
  type        = string
  description = "Password for the database"
}