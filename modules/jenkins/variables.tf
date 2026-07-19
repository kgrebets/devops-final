variable "namespace" {
  description = "Kubernetes namespace where Jenkins will be installed"
  type        = string
  default     = "jenkins"
}

variable "cluster_name" {
  description = "EKS cluster name used for naming Jenkins IAM roles"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS IAM OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS IAM OIDC provider"
  type        = string
}

variable "release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Version of the Jenkins Helm chart to install"
  type        = string
  default     = "5.8.27"
}

variable "admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "service_type" {
  description = "Kubernetes Service type used to expose Jenkins"
  type        = string
  default     = "LoadBalancer"
}

variable "agent_service_account_name" {
  description = "ServiceAccount used by Jenkins Kubernetes agents (Kaniko/Git pods)"
  type        = string
  default     = "jenkins-sa"
}

variable "github_username" {
  description = "GitHub username used for Jenkins Git credentials"
  type        = string
  default     = "CHANGE_ME"
}

variable "github_token" {
  description = "GitHub Personal Access Token used by Jenkins Git credentials"
  type        = string
  sensitive   = true
  default     = "CHANGE_ME"
}

variable "infra_repository_url" {
  description = "Repository URL where the Jenkinsfile is stored"
  type        = string
  default     = "https://github.com/CHANGE_ME/infra.git"
}

variable "pipeline_job_name" {
  description = "Name of the generated Jenkins pipeline job"
  type        = string
  default     = "goit-django-docker"
}

variable "app_repository_url" {
  description = "Application repository URL containing Dockerfile"
  type        = string
  default     = "https://github.com/CHANGE_ME/app.git"
}

variable "gitops_repository_url" {
  description = "GitOps repository URL containing Helm values.yaml to update"
  type        = string
  default     = "https://github.com/CHANGE_ME/gitops.git"
}

variable "gitops_values_file" {
  description = "Path to Helm values.yaml in the GitOps repository"
  type        = string
  default     = "charts/django-app/values.yaml"
}

variable "ecr_repository_url" {
  description = "Target ECR repository URL used by Jenkins pipeline"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region used by Jenkins pipeline"
  type        = string
  default     = "eu-north-1"
}
