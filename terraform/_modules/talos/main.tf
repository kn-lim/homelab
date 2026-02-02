resource "talos_machine_secrets" "default" {}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = var.node_data.controlplanes

  client_configuration        = talos_machine_secrets.default.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key

  config_patches = [
    # patches/
    file("${path.module}/patches/cluster-config.yaml"),
    file("${path.module}/patches/local-storage.yaml"),
    file("${path.module}/patches/machine-config.yaml"),
    file("${path.module}/patches/registry-mirror.yaml"),

    # templates/
    templatefile("${path.module}/templates/machine-config.yaml.tmpl", {
      install_disk = each.value.install_disk
      cluster_dns  = cidrhost(var.service_subnet, 10)
      node_subnet  = var.node_subnet
    }),
    templatefile("${path.module}/templates/network-config.yaml.tmpl", {
      hostname          = each.value.hostname
      network_interface = var.network_interface
      node_ip           = each.key
      gateway           = var.gateway
      dns_server        = var.dns_server
      node_subnet       = var.node_subnet
    }),
    templatefile("${path.module}/templates/cluster-config.yaml.tmpl", {
      node_subnet    = var.node_subnet
      pod_subnet     = var.pod_subnet
      service_subnet = var.service_subnet
    }),
  ]
}

# resource "talos_machine_configuration_apply" "worker" {
#   for_each = var.node_data.workers

#   client_configuration        = talos_machine_secrets.default.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
#   node                        = each.key

#   config_patches = []
# }

resource "talos_machine_bootstrap" "default" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.default.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "default" {
  depends_on = [talos_machine_bootstrap.default]

  client_configuration = talos_machine_secrets.default.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}
