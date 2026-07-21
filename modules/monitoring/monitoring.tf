resource "helm_release" "kube_prometheus_stack" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  create_namespace = true

  set {
    name  = "grafana.fullnameOverride"
    value = "grafana"
  }

  set {
    name  = "grafana.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "grafana.service.port"
    value = "80"
  }
}
