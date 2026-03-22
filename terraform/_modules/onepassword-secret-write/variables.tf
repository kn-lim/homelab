variable "field_name" {
  description = "Label of the field to store the value under"
  type        = string
}

variable "secret_name" {
  description = "Title of the 1Password item to create"
  type        = string
}

variable "value" {
  description = "Value to store in the field"
  type        = string
  sensitive   = true
}

variable "vault_name" {
  description = "Name of the 1Password vault"
  type        = string
}
