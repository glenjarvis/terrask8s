variable "home_office_ip" {
  description = "IP Address of the home/office network that is allowed to access K8s cluster"
  type        = string

  validation {
    condition     = can(cidrhost("${var.home_office_ip}/32", 0))
    error_message = "home_office_ip must be a bare IPv4 address without a CIDR suffix (e.g. 1.2.3.4)."
  }
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

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access to nodes"
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "key_name must be a non-empty string."
  }
}
