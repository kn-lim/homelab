locals {}

inputs = {
  namespace         = values.namespace
  token_secret_name = values.token_secret_name
}

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
