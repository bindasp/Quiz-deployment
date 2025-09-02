resource "helm_release" "argocd" {
  name       = var.helm_release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.namespace

  create_namespace = true
  version          = var.argocd_version

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

}

# resource "kubernetes_service" "argocd_service" {
#   metadata {
#     name      = "argocd-service"
#     namespace = var.namespace

#     annotations = {
#       "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
#       "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
#     }
#   }

#   spec {
#     selector = {
#       "app.kubernetes.io/name" = "argocd"
#       "service"                = "argocd"
#     }
#     port {
#       name        = "http"
#       port        = 80
#       target_port = 8080
#       protocol    = "TCP"
#     }
#     type = "LoadBalancer"
#   }

#   depends_on = [helm_release.argocd]
# }

