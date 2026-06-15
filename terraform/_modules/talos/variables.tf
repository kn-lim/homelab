# Optional Variables

# https://github.com/siderolabs/talos/releases

variable "kubernetes_version" {
  description = "Kubernetes version to pin in machine configuration"
  type        = string
  default     = null
}

variable "nvidia_gpu_enabled" {
  description = "Enable NVIDIA GPU support on Talos nodes"
  type        = bool
  default     = false
}

variable "talos_system_extensions" {
  description = "List of official Talos system extensions to install"
  type        = list(string)
  default     = [""]
}

variable "talos_version" {
  description = "Talos version for machine configuration schema"
  type        = string
  default     = "v1.13.4"
}

# Required Variables

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "dns_server" {
  description = "DNS server"
  type        = string
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "hardware_addr" {
  description = "Network interface hardware MAC address for Talos nodes"
  type        = string
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string, "")
    }))
  })
}

variable "node_subnet" {
  description = "Node subnet for kubelet nodeIP validation"
  type        = string
}

variable "pod_subnet" {
  description = "Pod subnet for Kubernetes pods"
  type        = string
}

variable "service_subnet" {
  description = "Service subnet for Kubernetes services"
  type        = string
}
