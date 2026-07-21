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

variable "postgres_host" {
  description = "PostgreSQL host override injected into the Django Helm chart values via Argo CD Application parameters"
  type        = string
  default     = ""
}

variable "postgres_port" {
  description = "PostgreSQL port override injected into the Django Helm chart values"
  type        = string
  default     = "5432"
}

variable "postgres_user" {
  description = "PostgreSQL user override injected into the Django Helm chart values"
  type        = string
  default     = ""
}

variable "postgres_db" {
  description = "PostgreSQL database name override injected into the Django Helm chart values"
  type        = string
  default     = ""
}

variable "postgres_password" {
  description = "PostgreSQL password override injected into the Django Helm chart secret values"
  type        = string
  default     = ""
  sensitive   = true
}

variable "django_debug" {
  description = "Django DEBUG value override"
  type        = string
  default     = "False"
}

variable "allowed_hosts" {
  description = "Comma-separated Django ALLOWED_HOSTS value"
  type        = string
  default     = "localhost,127.0.0.1"
}
