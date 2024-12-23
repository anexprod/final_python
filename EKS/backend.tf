terraform {
  backend "s3" {
    bucket         = "final-step"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}