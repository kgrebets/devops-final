# VPC name
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

# VPC CIDR block
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

# Public subnet CIDR blocks
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

# Private subnet CIDR blocks
variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

# Availability zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

