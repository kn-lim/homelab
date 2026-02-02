data "talos_client_configuration" "default" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.default.client_configuration
  endpoints            = [for k, v in var.node_data.controlplanes : k]
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.default.machine_secrets
  talos_version    = var.talos_version
}

# data "talos_machine_configuration" "worker" {
#   cluster_name     = var.cluster_name
#   cluster_endpoint = var.cluster_endpoint
#   machine_type     = "worker"
#   machine_secrets  = talos_machine_secrets.default.machine_secrets
# }
