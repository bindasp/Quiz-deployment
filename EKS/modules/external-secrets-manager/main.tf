locals {
  namespace = "external-secrets"
}

resource "aws_iam_policy" "external_secrets" {
  name   = "ExternalSecretsIAMPolicy"
  policy = file("${path.module}/external_secrets_iam_policy.json")
}

resource "aws_iam_role" "external_secrets" {
  name = "ExternalSecretsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.aws_iam_openid_connect_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:sub" = "system:serviceaccount:${local.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets_attach" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}


resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = local.namespace
  }

}

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = var.service_account_name
    namespace = local.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
    }
  }
}

resource "helm_release" "external_secrets" {
  name             = var.helm_release_name
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = local.namespace
  create_namespace = true
  set = [{
    name  = "serviceAccount.create"
    value = "false"
    },

    {
      name  = "serviceAccount.name"
      value = var.service_account_name
    },
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "cleanup.crds.enabled"
      value = "true"
    }
  ]

  depends_on = [
    kubernetes_namespace.external_secrets,
    kubernetes_service_account.external_secrets,
    aws_iam_role_policy_attachment.external_secrets_attach,
    # null_resource.apply_external_secrets_crds
  ]
}

# resource "null_resource" "apply_external_secrets_crds" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f \"https://raw.githubusercontent.com/external-secrets/external-secrets/${var.external_secrets_version}/deploy/crds/bundle.yaml\" --server-side"
#   }
# }
