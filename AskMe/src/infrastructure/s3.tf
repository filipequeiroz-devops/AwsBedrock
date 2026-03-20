resource "aws_s3_bucket" "bedrock_bucket" {
  bucket = "bedrock-bucket-askme"

  tags = {
    Name        = "BedrockBucket"
  }
}

