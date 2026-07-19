output "namespace" {
  description = "Kubernetes namespace where Jenkins is deployed"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "release_name" {
  description = "Helm release name of the Jenkins deployment"
  value       = helm_release.jenkins.name
}

output "release_status" {
  description = "Status of the Jenkins Helm release"
  value       = helm_release.jenkins.status
}

output "admin_user" {
  description = "Jenkins admin username"
  value       = var.admin_user
}

output "service_hostname" {
  description = "External LoadBalancer hostname of Jenkins service"
  value       = try(data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "agent_service_account_name" {
  description = "ServiceAccount used by Jenkins Kubernetes agents"
  value       = kubernetes_service_account.jenkins_sa.metadata[0].name
}

output "jenkins_kaniko_role_arn" {
  description = "IAM role ARN assumed by Jenkins Kubernetes agents via IRSA"
  value       = aws_iam_role.jenkins_kaniko_role.arn
}
