# Here we must set our profile, otherwise infra will be created in the root account
provider "aws" {
  region  = var.region
  profile = var.iam_profile
}

provider "kubernetes" {
  host                   = aws_eks_cluster.danit.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.danit.token
}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjunction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
#provider "http" {}

#terraform {
#  required_version = ">= 0.13"
#
#  required_providers {
#    kubectl = {
#      source  = "gavinbunney/kubectl"
#      version = ">= 1.7.0"
#    }
#  }
#}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.danit.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.danit.token
  }
}

# Развертывание Nginx Ingress Controller с помощью Helm
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.0"

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "eks_cluster_kubeconfig" {
  value = module.eks_cluster.kubeconfig
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.danit.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.danit.token
  }
}

# Развертывание ArgoCD с помощью Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.0.0"

  create_namespace = true

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.student1.devops4.test-danit.com"  # Замените на ваш DNS
  }

  set {
    name  = "server.ingress.annotations.kubernetes.io/ingress.class"
    value = "nginx"
  }

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.service.externalTrafficPolicy"
    value = "Local"
  }
}
