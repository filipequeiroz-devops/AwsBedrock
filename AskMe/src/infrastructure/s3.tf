resource "aws_s3_bucket" "knowledge_base" {
  bucket = "${var.company_name}-ai-knowledge"
}

resource "aws_s3_object" "knowledge_files" {
  for_each = fileset("${path.module}/docs", "*.txt")

  bucket       = aws_s3_bucket.knowledge_base.id
  key          = "knowledge/${each.value}"
  source       = "${path.module}/docs/${each.value}"
  etag         = filemd5("${path.module}/docs/${each.value}") # Forces upload if the files changes
  content_type = "text/plain"
}