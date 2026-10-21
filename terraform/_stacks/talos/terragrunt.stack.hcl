unit "talos" {
  source = "${find_in_parent_folders("_units/talos")}"

  path = "talos"

  values = merge(
    {
      cluster_endpoint = values.talos.endpoint
      cluster_name     = values.talos.name

      dns_server = values.talos.dns_server
      gateway    = values.talos.gateway

      node_data      = values.talos.node_data
      node_subnet    = values.talos.node_subnet
      service_subnet = values.talos.service_subnet
      pod_subnet     = values.talos.pod_subnet
    },
    try(values.talos.hardware_addr, null) != null ? { hardware_addr = values.talos.hardware_addr } : {},
    try(values.talos.talos_version, null) != null ? { talos_version = values.talos.talos_version } : {},
    try(values.talos.nvidia_gpu_enabled, null) != null ? { nvidia_gpu_enabled = values.talos.nvidia_gpu_enabled } : {},
    try(values.talos.kubernetes_version, null) != null ? { kubernetes_version = values.talos.kubernetes_version } : {},
    try(values.talos.system_extensions, null) != null ? { system_extensions = values.talos.system_extensions } : {},
    try(values.talos.virtiofs_volumes, null) != null ? { virtiofs_volumes = values.talos.virtiofs_volumes } : {},
    try(values.talos.directory_volumes, null) != null ? { directory_volumes = values.talos.directory_volumes } : {},
  )
}
