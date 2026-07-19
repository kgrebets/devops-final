# ECR repository name
variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
}

# Enable image scanning on push
variable "scan_on_push" {
  description = "Enable image scanning when an image is pushed"
  type        = bool
}