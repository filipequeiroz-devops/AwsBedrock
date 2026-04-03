# IA's History management
resource "aws_dynamodb_table" "users_table" {
  name         = "${var.company_name}-history-table"
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

## Appointments table (how it wa before)
#resource "aws_dynamodb_table" "appointments_table" {
#  name         = "${var.company_name}-appointments-table"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key     = "UserId"
#  range_key    = "Timestamp"
#
#  attribute {
#    name = "UserId"
#    type = "S" #String type for user id
#  }
#
#  attribute {
#    name = "Timestamp"
#    type = "S" #String type for timestamp
#   }
#}

#now the logic will be different
resource "aws_dynamodb_table" "appointments_table" {
  name         = "${var.company_name}-appointments-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ServiceData"
  range_key    = "BarbeiroId#HorarioInicio" #composite key to allow multiple entries for the same user, ordered by timestamp

  attribute {
    name = "ServiceData"
    type = "S" #String type for user id
  }

  attribute {
    name = "BarbeiroId#HorarioInicio"
    type = "S" #String type for timestamp
  }

}