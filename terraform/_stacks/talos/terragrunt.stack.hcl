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
    try(values.talos.network_interface, null) != null ? { network_interface = values.talos.network_interface } : {},
    try(values.talos.talos_version, null) != null ? { talos_version = values.talos.talos_version } : {},
  )
}

unit "onepassword-secret" {
  source = "${find_in_parent_folders("_units/onepassword-secret")}"

  path = "onepassword-secret"

  values = {
    vault_name  = values.cluster-bootstrap.vault_name
    secret_name = values.cluster-bootstrap.secret_name
  }
}

unit "cluster-bootstrap" {
  source = "${find_in_parent_folders("_units/cluster-bootstrap")}"

  path = "cluster-bootstrap"

  values = {
    namespace         = values.cluster-bootstrap.namespace
    token_secret_name = values.cluster-bootstrap.token_secret_name
  }
}
