locals {}

inputs = {
  clusters = [for cluster in yamldecode(file("${get_repo_root()}/clusters.yaml")).clusters : cluster.name]
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/grafana/alert-rules")}"
}
