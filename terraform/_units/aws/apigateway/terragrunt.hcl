locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
}

inputs = {
  name               = "${values.name}-apigateway"
  protocol_type      = "HTTP"
  create_domain_name = false

  stage_access_log_settings = {
    log_group_retention_in_days = 1
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/apigateway-v2/aws?version=6.1.1"
}
