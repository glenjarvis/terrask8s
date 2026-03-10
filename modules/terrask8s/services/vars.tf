variable "project" {
  description = "Name of project using this service"
  type        = string
  default     = "terrask8s"

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty string."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, stage, prod)."
  type        = string

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must be a non-empty string (e.g. dev, stage, prod)."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the node"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the EC2 node. If null, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-", var.ami_id))
    error_message = "ami_id must be a valid AMI ID starting with 'ami-'."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs in which to launch nodes (one node per subnet)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the node"
  type        = list(string)
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "key_name must be a non-empty string."
  }
}

variable "tags" {
  description = "Tags for service resources"
  type        = map(string)
  default     = {}
}