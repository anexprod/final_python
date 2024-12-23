# IAM Role для ExternalDNS
resource "aws_iam_role" "external_dns_role" {
  name = "external-dns-role"

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
    { Name = "external-dns-role" }
  )
}

# Политика для ExternalDNS
resource "aws_iam_policy" "external_dns_policy" {
  name        = "external-dns-policy"
  description = "Policy for ExternalDNS to manage Route 53 records"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets", "route53:ListHostedZones"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Прикрепляем IAM политику к роли для ExternalDNS
resource "aws_iam_role_policy_attachment" "attach_external_dns_policy" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}