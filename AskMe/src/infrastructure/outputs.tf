output "ec2_instance_public_ips" {
  value = aws_instance.askme.*.public_ip
  description = "Public IP addresses of the EC2 instances"
}