locals {
  namespace = "argocd"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = local.namespace
  }


}

resource "helm_release" "argocd" {
  name       = var.helm_release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = local.namespace

  version = var.argocd_version

  timeout = 900
  wait    = true

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    },
    {
      name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internet-facing"
    },
    {
      name  = "server.labels.service"
      value = "argocd"
    },

    {
      name  = "server.extraArgs[0]"
      value = "--insecure"
    },
    {
      name  = "server.podLabels.service"
      value = "argocd"
    }
  ]

  depends_on = [kubernetes_namespace.argocd]
}

