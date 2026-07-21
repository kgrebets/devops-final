variable "namespace" {
  description = "Namespace for metrics-server"
  type        = string
  default     = "kube-system"
}

variable "release_name" {
  description = "Helm release name for metrics-server"
  type        = string
  default     = "metrics-server"
}

variable "chart_version" {
  description = "Version of metrics-server Helm chart"
  type        = string
  default     = "3.12.2"
}
