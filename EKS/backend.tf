terraform {
  backend "s3" {
    bucket         = "final-step"
    key            = "terraform.tfstate"
    encrypt        = true
    dynamodb_table = "lock-tf-final-step"
    region         = "us-east-1"
  }
}