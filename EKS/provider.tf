# Провайдер для AWS
provider "aws" {
  region  = var.region
  profile = var.iam_profile
}

# Провайдер для Kubernetes
provider "kubernetes" {
  host                   = aws_eks_cluster.danit.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.danit.token
}

# Провайдер для Helm
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.danit.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.danit.token
  }
}

# Провайдер для Route 53
data "aws_route53_zone" "example" {
  name = "test-danit.com."  # Замените на ваш домен
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

# Создание DNS-записи для ArgoCD в Route 53
resource "aws_route53_record" "argocd" {
  zone_id = data.aws_route53_zone.example.id
  name    = "argocd.student1.devops4.test-danit.com"  # Замените на ваше имя
  type    = "CNAME"
  ttl     = 300
  records = [helm_release.argocd.status.load_balancer[0].ingress[0].hostname]  # Получение адреса из Helm
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
