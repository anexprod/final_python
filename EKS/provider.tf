# Security Group for EKS
resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "EKS Security Group"
  vpc_id      = var.vpc_id
}

# AWS EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnets_ids
    security_group_ids = [aws_security_group.eks_security_group.id]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
      }
    ]
  })
}

# Data resource for EKS cluster authentication
data "aws_eks_cluster_auth" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}

# External DNS Module Configuration
module "eks-external-dns-fs17-instance" {
  source  = "lablabs/eks-external-dns/aws"
  version = "1.2.0"

  cluster_identity_oidc_issuer_arn = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer     = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer

  settings = {
    domainFilters = var.zone_name  # Строка, а не список
    policy        = "sync"
    aws_region    = var.region
  }

  service_account_name = "external-dns"
  namespace            = "default"
}
