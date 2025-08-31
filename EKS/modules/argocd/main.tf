resource "helm_release" "argocd" {
  name       = var.helm_release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.namespace

  create_namespace = true
  version          = var.argocd_version


  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
  extraArgs:
    - --insecure
EOF
  ]
}


# data "kubernetes_secret" "argocd_admin" {
#   metadata {
#     name      = "argocd-initial-admin-secret"
#     namespace = "argocd"
#   }
#   depends_on = [helm_release.argocd]
# }

# output "argocd_password" {
#   value     = data.kubernetes_secret.argocd_admin.data["password"]
#   sensitive = true
# }
# provider "argocd" {
#   server_addr = "argocd-server.argocd.svc.cluster.local:80"
#   username    = "admin"
#   password    = base64decode(data.kubernetes_secret.argocd_admin.data["password"])
#   insecure    = true
# }

# resource "argocd_repository" "git" {
#   repo     = "https://github.com/bindasp/Quiz-deployment.git"
#   username = var.github_user
#   password = var.github_token
# }

# resource "argocd_project" "default" {
#   metadata {
#     name      = "default"
#     namespace = "argocd"
#   }

#   spec {
#     description  = "Quiz app project"
#     source_repos = ["*"]
#     destination {
#       server    = "https://kubernetes.default.svc"
#       namespace = "*"
#     }
#     cluster_resource_whitelist {
#       group = "*"
#       kind  = "*"
#     }
#   }
# }

# resource "argocd_application" "quiz_app" {
#   metadata {
#     name      = "quiz-app"
#     namespace = "argocd"
#   }

#   spec {
#     project = argocd_project.default.metadata[0].name

#     source {
#       repo_url        = argocd_repository.git.repo
#       target_revision = "main"
#       path            = "k8s/backend"
#     }

#     destination {
#       server    = "https://kubernetes.default.svc"
#       namespace = "quiz"
#     }

#     sync_policy {
#       automated {
#         prune     = true
#         self_heal = true
#       }
#     }
#   }

#   depends_on = [helm_release.argocd]
# }
