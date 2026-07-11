# Required Variables

variable "nameservers" {
  description = "List of global nameserver IP addresses for the tailnet"
  type        = list(string)
}

# Optional Variables

variable "magic_dns" {
  description = "Whether MagicDNS is enabled for the tailnet"
  type        = bool
  default     = true
}

variable "override_local_dns" {
  description = "Whether devices ignore their local DNS and always use the global nameservers"
  type        = bool
  default     = true
}
