#History management
resource "aws_dynamodb_table" "askme_table" {
  name           = "askme-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"
  range_key       = "timestamp" #sort key to allow multiple entries for the same session_id, ordered by timestamp

  attribute {
    name = "session_id"
    type = "S" #String type for session_id
  }

  attribute {
    name = "timestamp"
    type = "N" #Number type for timestamp
  }
}