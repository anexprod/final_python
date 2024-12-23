# Ресурс VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Ресурсы подсетей
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"  # Зона доступности для региона eu-central-1
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"  # Зона доступности для региона eu-central-1
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-b"
  }
}

# Ресурс EKS Cluster
resource "aws_eks_cluster" "danit" {
  name     = var.name
  role_arn = aws_iam_role.fs17_eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]  # Используем ID подсетей напрямую
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}" }
  )
}

# IAM Role для EKS Cluster
resource "aws_iam_role" "fs17_eks_cluster_role" {
  name = "fs17_eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })

  tags = merge(
    var.tags,
    { Name = "fs17-eks-cluster-role" }
  )
}

# Создание группы безопасности для EKS
resource "aws_security_group" "fs17_cluster_sg" {
  name        = "fs17_cluster_sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = "fs17-cluster-sg" }
  )
}

# IAM Role для рабочих узлов
resource "aws_iam_role" "fs17-node-role" {
  name = "unique-danit-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })

  tags = merge(
    var.tags,
    { Name = "fs17-node-role" }
  )
}

# Создание node группы для EKS
resource "aws_eks_node_group" "fs17_eks_node_group" {
  cluster_name    = aws_eks_cluster.danit.name  # Исправил имя ресурса на "danit"
  node_group_name = "fs17-node-group"
  node_role_arn   = aws_iam_role.fs17-node-role.arn
  subnet_ids      = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]  # Прямо указываем ID подсетей

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.micro"]
  labels = {
    "node-type" = "general"
  }

  tags = merge(
    var.tags,
    { Name = "fs17-node-group" }
  )
}

# Передача ID подсетей в переменную при запуске
output "subnets_ids" {
  value = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}
