# Required Variables

variable "namespace" {
  description = "Namespace to create the Kubernetes resources in."
  type        = string
}

variable "token" {
  description = "Token value from 1Password."
  type        = string
  sensitive   = true
}

variable "token_secret_name" {
  description = "Name of Kubernetes Secret containing the token."
  type        = string
}
