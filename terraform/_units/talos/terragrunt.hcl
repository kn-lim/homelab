locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
}

inputs = merge(
  {
    cluster_endpoint = values.cluster_endpoint
    cluster_name     = values.cluster_name
    dns_server       = values.dns_server
    gateway          = values.gateway
    node_data        = values.node_data
    node_subnet      = values.node_subnet
    pod_subnet       = values.pod_subnet
    service_subnet   = values.service_subnet
  },
  try(values.network_interface, null) != null ? { network_interface = values.network_interface } : {},
  try(values.talos_version, null) != null ? { talos_version = values.talos_version } : {},
)

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/talos")}"

  after_hook "write_kubeconfig" {
    commands = ["apply"]
    execute  = ["bash", "-c", "\"$TG_CTX_TF_PATH\" output -raw kubeconfig > ${get_repo_root()}/${local.platform}-${local.region}.kubeconfig"]
  }

  after_hook "write_talosconfig" {
    commands = ["apply"]
    execute  = ["bash", "-c", "\"$TG_CTX_TF_PATH\" output -raw talosconfig > ${get_repo_root()}/${local.platform}-${local.region}.talosconfig"]
  }
}
