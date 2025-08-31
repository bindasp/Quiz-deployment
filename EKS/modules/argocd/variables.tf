variable "github_user" {
  description = "Github username"
  type        = string

}

variable "github_token" {
  description = "Github access token"
  type        = string
}

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
