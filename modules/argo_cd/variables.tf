variable "name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "5.46.4"
}

variable "applications_chart_version" {
  description = "Version of local argo-apps chart"
  type        = string
  default     = "0.1.0"
}

variable "gitops_repo_url" {
  description = "Git repository URL containing the Helm chart Argo CD should sync"
  type        = string
}

variable "gitops_repo_branch" {
  description = "Git branch Argo CD tracks"
  type        = string
  default     = "main"
}

variable "gitops_chart_path" {
  description = "Path inside Git repository to the target Helm chart"
  type        = string
  default     = "modules/charts/django-app"
}

variable "app_name" {
  description = "Argo CD Application name"
  type        = string
  default     = "django-app"
}

variable "app_namespace" {
  description = "Destination Kubernetes namespace for the application"
  type        = string
  default     = "default"
}

variable "argocd_project" {
  description = "Argo CD project for the application"
  type        = string
  default     = "default"
}

variable "repo_username" {
  description = "Username for Git repository access"
  type        = string
  default     = ""
}

variable "repo_password" {
  description = "Password or token for Git repository access"
  type        = string
  default     = ""
  sensitive   = true
}
