# Security Group for EKS
resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "EKS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnets_ids
    security_group_ids = [aws_security_group.eks_security_group.id]
  }

  depends_on = [aws_iam_role.eks_cluster_role]
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

# IAM Policies for EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# External DNS Module
module "eks-external-dns" {
  source  = "lablabs/eks-external-dns/aws"
  version = "1.2.0"

  cluster_identity_oidc_issuer_arn = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer     = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer

  settings = {
    domainFilters = var.zone_name
    policy        = "sync"
    aws_region    = var.region
  }

  service_account_name = "external-dns"
  namespace            = "default"

  depends_on = [aws_eks_cluster.my_cluster]
}

# Provider Configuration
provider "aws" {
  region = var.region
}
