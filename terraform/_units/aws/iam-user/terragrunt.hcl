locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
}

inputs = {
  name                 = "${values.name}-iam-user"
  create_access_key    = true
  create_login_profile = false
  create_inline_policy = true
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-user?version=6.8.0"
}
