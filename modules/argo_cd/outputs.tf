output "namespace" {
  description = "Namespace where Argo CD is installed"
  value       = var.namespace
}

output "release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argo_cd.name
}

output "argo_cd_server_service" {
  description = "Internal Argo CD server service address"
  value       = "${helm_release.argo_cd.name}-server.${var.namespace}.svc.cluster.local"
}

output "admin_password_command" {
  description = "Command to fetch initial Argo CD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}
