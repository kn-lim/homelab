stack "talos" {
  source = "${find_in_parent_folders("_stacks/talos")}"

  path = "talos"

  values = {
    talos = {
      name       = "ellinia"
      endpoint   = "https://talos.ellinia.knlim.dev:6443"
      dns_server = "1.1.1.3"
      gateway    = "10.1.2.1"

      hardware_addr = "a0:ce:c8:ce:86:1e"

      talos_version = "v1.14.1"

      kubernetes_version = "v1.37.0"

      system_extensions = [
        "siderolabs/amd-ucode",
      ]

      directory_volumes = [
        "democratic-csi",
      ]

      node_data = {
        controlplanes = {
          "10.1.2.20" = {
            install_disk = "/dev/nvme0n1"

            hostname = "ellinia"
          }
        }
      }
      node_subnet    = "10.1.2.0/24"
      service_subnet = "10.96.0.0/16"
      pod_subnet     = "10.244.0.0/16"
    }
  }
}
