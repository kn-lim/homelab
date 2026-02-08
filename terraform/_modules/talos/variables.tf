# Optional Variables

variable "network_interface" {
  description = "Network interface name for Talos nodes"
  type        = string
  default     = "ens18"
}

# https://github.com/siderolabs/talos/releases
variable "talos_version" {
  description = "Talos version for machine configuration schema"
  type        = string
  default     = "v1.12.3"
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

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = optional(string, "/dev/sda")
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
