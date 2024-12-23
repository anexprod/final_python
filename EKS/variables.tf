variable "name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "fs17_eks_cluster"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = "vpc-048b9b233174df7c3"
}

variable "subnets_ids" {
  description = "Subnets for the EKS cluster"
  type        = list(string)
  default     = ["subnet-076954e934f5108ec", "subnet-0656b074c26aae29d"]
}

variable "tags" {
  description = "Tags for AWS resources"
  type        = map(string)
  default     = {
    "Owner"      = "Eugene"
    "Environment" = "development"
  }
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "zone_name" {
  description = "DNS zone name"
  default     = "devops4.test-danit.com"
}

variable "iam_profile" {
  description = "Profile of AWS credentials"
  default     = null
}
