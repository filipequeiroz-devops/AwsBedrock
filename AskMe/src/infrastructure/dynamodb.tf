#History management
resource "aws_dynamodb_table" "users_table" {
  name         = "${var.company_name}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  range_key    = "Timestamp" #sort key to allow multiple entries for the same session_id, ordered by timestamp

  attribute {
    name = "UserId"
    type = "S" #String type for session_id
  }

  attribute {
    name = "Timestamp"
    type = "S" #String type for timestamp
  }
}