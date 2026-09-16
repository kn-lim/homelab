stack "talos" {
  source = "${find_in_parent_folders("_stacks/talos")}"

  path = "talos"

  values = {
    talos = {
      name       = "homelab-lenovo"
      endpoint   = "https://talos.homelab-lenovo.knlim.dev:6443"
      dns_server = "1.1.1.3"
      gateway    = "10.1.2.1"

      hardware_addr = "a0:ce:c8:ce:86:1e"

      talos_version = "v1.13.9"

      kubernetes_version = "v1.36.4"

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

            hostname = "homelab-lenovo"
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

      argocd_registration = {
        cluster_endpoint = "https://talos.homelab-lenovo.knlim.dev:6443"
        vault_name       = "Homelab"
        secret_name      = "argocd-cluster-homelab-lenovo"
      }
    }
  }
}
