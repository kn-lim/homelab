# Optional Variables

variable "argocd_registration" {
  description = "Register this cluster with a remote ArgoCD hub by storing manager credentials in 1Password. Null disables registration."
  type = object({
    cluster_endpoint = string
    vault_name       = string
    secret_name      = string
  })
  default = null
}

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
