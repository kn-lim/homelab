locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region

  account_id = run_cmd("aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text")
  invoke_arn = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.region}:${local.account_id}:function:${values.name}-lambda/invocations"
}

inputs = {
  name               = "${values.name}-apigateway"
  protocol_type      = "HTTP"
  create_domain_name = false

  stage_access_log_settings = {
    log_group_retention_in_days = 1
  }

  routes = {
    "POST /" = {
      integration = {
        uri                    = local.invoke_arn
        payload_format_version = "2.0"
      }
    }
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/apigateway-v2/aws?version=6.1.0"
}
