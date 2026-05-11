data "talos_client_configuration" "default" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.default.client_configuration
  endpoints            = [for k, v in var.node_data.controlplanes : k]
}

data "talos_image_factory_extensions_versions" "default" {
  talos_version = var.talos_version
  exact_filters = {
    names = concat(
      ["qemu-guest-agent"],
      var.nvidia_gpu_enabled ? ["nonfree-kmod-nvidia", "nvidia-container-toolkit"] : [],
      var.talos_system_extensions
    )
  }
}

data "talos_image_factory_urls" "default" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.default.id
  platform      = "metal"
  architecture  = "amd64"
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.default.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

# data "talos_machine_configuration" "worker" {
#   cluster_name     = var.cluster_name
#   cluster_endpoint = var.cluster_endpoint
#   machine_type     = "worker"
#   machine_secrets  = talos_machine_secrets.default.machine_secrets
# }
