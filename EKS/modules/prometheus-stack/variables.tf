variable "helm_release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
}

variable "chart_version" {
  description = "Kube-prometheus-stack chart version"
  type        = string
}
