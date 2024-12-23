resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.name}.${var.zone_name}"
  }

  set {
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
    name  = "server.insecure"
    value = "true"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  depends_on = [
    helm_release.nginx_ingress,
    aws_eks_node_group.danit-amd
  ]
}

data "kubernetes_secret" "argocd_secret" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}