variable "fields" {
  description = "Map of field labels to values to store in the 1Password item. All fields are stored as CONCEALED."
  type        = map(string)
  sensitive   = true
}

variable "secret_name" {
  description = "Title of the 1Password item to create"
  type        = string
}

variable "vault_name" {
  description = "Name of the 1Password vault"
  type        = string
}
