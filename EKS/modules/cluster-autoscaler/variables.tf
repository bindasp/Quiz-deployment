variable "service_account_name" {
  description = "Cluster autoscaler name"
  type        = string
}

variable "region" {
  description = "AWS region"
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
  description = "Helm chart name for ALB controller"
  type        = string
}

variable "cluster_name" {
  description = "AWS cluster name"
  type        = string
}
