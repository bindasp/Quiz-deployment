resource "helm_release" "metrics_server" {
  name       = var.helm_release_name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = var.namespace

}
