output "release_name" {
  description = "Helm release name of metrics-server"
  value       = helm_release.metrics_server.name
}
