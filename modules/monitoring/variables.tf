variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "kube-prometheus-stack"
}

variable "chart_version" {
  description = "Version of kube-prometheus-stack chart"
  type        = string
  default     = "61.7.2"
}
