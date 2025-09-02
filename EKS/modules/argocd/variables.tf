variable "helm_release_name" {
  description = "Helm release name for ArgoCD"
  type        = string
}

variable "namespace" {
  description = "ArgoCD namespace"
  type        = string
}

variable "argocd_version" {
  description = "ArgoCD version"
  type        = string
}

variable "argocd_password" {
  description = "ArgoCD password"
  type        = string
}
