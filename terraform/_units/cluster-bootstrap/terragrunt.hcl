locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region

  # Same path root.hcl hands to the kubernetes provider; the hook must target the same cluster.
  kubeconfig_path = "${get_repo_root()}/${local.platform}-${local.region}.kubeconfig"
}

inputs = merge(
  {
    namespace         = values.namespace
    token_secret_name = values.token_secret_name
  },
  try(values.argocd_registration, null) != null ? { argocd_registration = values.argocd_registration } : {},
)

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/cluster-bootstrap")}"

  # Create namespace if it doesn't already exist
  before_hook "create_namespace" {
    commands = ["apply"]
    execute  = ["bash", "-c", "kubectl --kubeconfig ${local.kubeconfig_path} get namespace ${values.namespace} >/dev/null 2>&1 || kubectl --kubeconfig ${local.kubeconfig_path} create namespace ${values.namespace}"]
  }
}
