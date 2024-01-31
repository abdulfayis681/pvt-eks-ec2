terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "production-terraform-state456"
    dynamodb_table = "production-terraform-state-lock"
    region         = "us-east-2"
    key            = "statefile/terraform.tfstate"
  }
}