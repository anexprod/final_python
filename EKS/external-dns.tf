module "eks-external-dns-fs17-instance-2" {
  source  = "lablabs/eks-external-dns/aws"
  version = "1.2.0"

  cluster_identity_oidc_issuer_arn = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer     = aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer

  settings = {
    domainFilters = var.zone_name  # Передаем строку вместо списка
    policy        = "sync"
    aws_region    = var.region     # Регион также передается как строка
  }

  service_account_name = "external-dns"
  namespace            = "default"
}
