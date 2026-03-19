resource "aws_instance" "askme" {
  count         = 2 
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "AskMeInstance"
  }
}