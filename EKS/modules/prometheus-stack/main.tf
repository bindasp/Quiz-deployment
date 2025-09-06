locals {
  namespace = "monitoring"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "prometheus" {
  name       = var.helm_release_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = local.namespace
  version    = var.chart_version


  depends_on = [kubernetes_namespace.monitoring]

  values = [
    <<EOF

prometheus:
    service:
      type: LoadBalancer
      port: 9090
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
grafana:
  service:
    type: LoadBalancer
    port: 80
    targetPort: 3000
    annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
  adminUser: admin
  adminPassword: changeme

nodeExporter:
    enabled: true

kube-state-metrics:
    enabled: true
EOF
  ]

}
