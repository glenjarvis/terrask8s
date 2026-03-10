
variable "home_office_ip" {
  description = "IP Address of Home or Office who will be able to access K8s cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of previously created Virtual Private Cloud (VPC)"
  type        = string
}
