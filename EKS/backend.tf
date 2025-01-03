terraform {
  backend "s3" {
    bucket         = "step-final"
    key            = "terraform.tfstate"
    region         =  "eu-central-1"
    encrypt        = true
    dynamodb_table = "lock-tf-step-final"
  }
}