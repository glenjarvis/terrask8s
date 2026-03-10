variable "home_office_ip" {
  description = "IP Address of Home or Office who will be able to access K8s cluster"
  type        = string

  validation {
    condition     = can(cidrhost("${var.home_office_ip}/32", 0))
    error_message = "home_office_ip must be a bare IPv4 address without a CIDR suffix (e.g. 1.2.3.4)."
  }
}
