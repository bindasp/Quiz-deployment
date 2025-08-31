variable "service_account_name" {
  description = "service account name for external secrets"
  type        = string
}

variable "aws_iam_openid_connect_provider_url" {
  description = "IAM oidc url"
  type        = string
}

variable "aws_iam_openid_connect_provider_arn" {
  description = "IAM oidc arn"
  type        = string
}

variable "helm_release_name" {
  description = "Helm release name for external secrets"
  type        = string
}

variable "external_secrets_version" {
  description = "External secrets version"
  type        = string
}
