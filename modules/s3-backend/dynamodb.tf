//creates table in DynamoDB for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  //LockID is default key by Terraform and is used to identify the lock for a given state file
  hash_key = "LockID"

  attribute {
    name = "LockID" //the name of the attribute that will be used as the hash key
    type = "S"      //S-string
  }
}