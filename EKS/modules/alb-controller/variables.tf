variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "AWS vpc id"
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

variable "service_account_name" {
  description = "Kubernetes service account name for alb"
  type        = string
}

variable "helm_release_name" {
  description = "Helm release name for ALB controller"
  type        = string
}


variable "cluster_name" {
  description = "AWS cluster name"
  type        = string
}
