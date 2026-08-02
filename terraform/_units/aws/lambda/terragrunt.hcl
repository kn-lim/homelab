locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
}

inputs = {
  function_name = "${values.name}-lambda"
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"]
  timeout       = 30

  create_package          = false
  ignore_source_code_hash = true

  s3_existing_package = {
    bucket = values.s3_bucket
    key    = values.s3_key
  }

  attach_policy_json = true

  cloudwatch_logs_retention_in_days = 1
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/lambda/aws?version=8.8.0"
}
