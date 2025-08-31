variable "namespace" {
  description = "Metrics server namespace"
  type        = string
}

variable "helm_release_name" {
  description = "Helm release name for metrics server"
  type        = string
}
