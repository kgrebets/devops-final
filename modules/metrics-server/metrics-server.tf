resource "helm_release" "metrics_server" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.chart_version
  create_namespace = false

  # Required in many managed clusters where kubelet certs are not signed for node IPs.
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}
