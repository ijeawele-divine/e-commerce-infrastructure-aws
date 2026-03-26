resource "aws_iam_policy" "external_secrets_policy" {
  name        = "teleios-divine-${var.environment}-external-secrets-policy"
  description = "Allows External Secrets Operator to read from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.rider_service.arn,
          aws_secretsmanager_secret.driver_service.arn,
          aws_secretsmanager_secret.trip_service.arn,
          aws_secretsmanager_secret.matching_service.arn,
          aws_secretsmanager_secret.email_service.arn,
          aws_secretsmanager_secret.frontend.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "external_secrets_role" {
  name = "teleios-divine-${var.environment}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}