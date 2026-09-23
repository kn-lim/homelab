stack "talos" {
  source = "${find_in_parent_folders("_stacks/talos")}"

  path = "talos"

  values = {
    talos = {
      name       = "homelab"
      endpoint   = "https://talos.homelab.knlim.dev:6443"
      dns_server = "1.1.1.3"
      gateway    = "10.1.2.1"

      hardware_addr = "52:54:00:fe:bd:6a"

      talos_version = "v1.14.1"

      kubernetes_version = "v1.37.0"

      nvidia_gpu_enabled = true

      system_extensions = [
        "siderolabs/qemu-guest-agent",
      ]

      virtiofs_volumes = [
        "kubernetes-array",
        "kubernetes-data",
        "media",
      ]

      node_data = {
        controlplanes = {
          "10.1.2.11" = {
            install_disk = "/dev/vda"

            hostname = "homelab-talos"
          }
        }
      }
      node_subnet    = "10.1.2.0/24"
      service_subnet = "10.96.0.0/16"
      pod_subnet     = "10.244.0.0/16"
    }

    cluster-bootstrap = {
      namespace         = "external-secrets"
      vault_name        = "Homelab"
      secret_name       = "op-sa-kubernetes"
      token_secret_name = "onepassword-token"
    }
  }
}
