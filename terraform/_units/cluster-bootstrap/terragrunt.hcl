locals {}

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
    execute  = ["bash", "-c", "kubectl get namespace ${values.namespace} >/dev/null 2>&1 || kubectl create namespace ${values.namespace}"]
  }
}
