stack "talos" {
  source = "${find_in_parent_folders("_stacks/talos")}"

  path = "talos"

  values = {
    talos = {
      name       = "homelab"
      endpoint   = "https://talos.homelab.knlim.dev:6443"
      dns_server = "1.1.1.3"
      gateway    = "10.1.2.1"

      node_data = {
        controlplanes = {
          "10.1.2.11" = {
          }
        }
      }
      node_subnet    = "10.1.2.0/24"
      service_subnet = "10.96.0.0/16"
      pod_subnet     = "10.244.0.0/16"
    }

    cluster-bootstrap = {
      namespace = "cluster-services"

      vault_name  = "Homelab"
      secret_name = "op-sa-kubernetes-token"

      token_secret_name = "onepassword-token"
    }
  }
}
