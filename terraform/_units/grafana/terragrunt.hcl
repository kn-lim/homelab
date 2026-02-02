locals {}

inputs = {
  dashboards         = values.dashboards
  prometheus_sources = values.prometheus_sources
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/grafana")}"
}
