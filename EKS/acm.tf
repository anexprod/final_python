# Получаем Route 53 Hosted Zone для вашего домена
data "aws_route53_zone" "zone" {
  name         = "devops4.test-danit.com"
  private_zone = false                     
}

locals {
  domain_name = "${var.name}.devops4.test-danit.com" 
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = local.domain_name 
  zone_id     = data.aws_route53_zone.zone.zone_id

  subject_alternative_names = [
    "*.${local.domain_name}", 
  ]

  wait_for_validation = true  

  tags = merge(
    var.tags,
    { Name = "${var.name}-eks" }
  )
}
