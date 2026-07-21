output "namespace" {
  description = "Namespace where monitoring stack is installed"
  value       = var.namespace
}

output "release_name" {
  description = "Helm release name of kube-prometheus-stack"
  value       = helm_release.kube_prometheus_stack.name
}

output "grafana_service" {
  description = "Grafana service name"
  value       = "grafana"
}

output "prometheus_service" {
  description = "Prometheus service name"
  value       = "${helm_release.kube_prometheus_stack.name}-kube-p-prometheus"
}
