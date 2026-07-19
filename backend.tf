terraform {
  backend "s3" {
    bucket         = "terraform-state-devops-homework-5-1"
    key            = "lesson-10/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}