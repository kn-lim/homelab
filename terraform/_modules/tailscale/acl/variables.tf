# Required Variables

variable "acl" {
  description = "The tailnet policy file as a JSON or HuJSON string"
  type        = string
}

# Optional Variables

variable "overwrite_existing_content" {
  description = "Whether to overwrite the existing policy file without importing it into state first"
  type        = bool
  default     = true
}

variable "reset_acl_on_destroy" {
  description = "Whether to reset the policy file to the Tailscale default when this resource is destroyed"
  type        = bool
  default     = false
}
