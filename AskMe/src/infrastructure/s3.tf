resource "aws_s3_bucket" "barbearia_knowledge_base" {
  bucket = "barbearia-ai-knowledge"
  
}

resource "aws_s3_object" "conhecimento_files" {
  for_each = fileset("${path.module}/docs", "*.txt")

  bucket = aws_s3_bucket.barbearia_knowledge_base.id
  key    = "conhecimento/${each.value}"
  source = "${path.module}/docs/${each.value}"
  etag   = filemd5("${path.module}/docs/${each.value}") # Forces upload if the files changes
  content_type = "text/plain"
}