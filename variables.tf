variable "rds_master_password" {
  description = "Master password for the RDS/Aurora database. Pass via TF_VAR_rds_master_password or a non-committed tfvars file."
  type        = string
  sensitive   = true
}

variable "jenkins_admin_password" {
  description = "Admin password for Jenkins. Pass via TF_VAR_jenkins_admin_password or a non-committed tfvars file."
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub personal access token used by Jenkins. Leave empty only for public-repo workflows that do not require authentication."
  type        = string
  sensitive   = true
  default     = ""
}

variable "argocd_repo_password" {
  description = "Password or token for Argo CD Git repository access. Leave empty only when the tracked repository is public."
  type        = string
  sensitive   = true
  default     = ""
}