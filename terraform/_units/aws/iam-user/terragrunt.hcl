locals {
  platform = read_terragrunt_config(find_in_parent_folders("platform.hcl")).locals.platform
  region   = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
}

# TODO: This needs to exist due to lack of support for units passing outputs directly between each other in a stack.
#       https://github.com/gruntwork-io/terragrunt/issues/4067
#       https://github.com/gruntwork-io/terragrunt/issues/5663
dependency "sqs" {
  config_path = "../sqs"
}

inputs = {
  name                 = "${values.name}-iam-user"
  create_access_key    = true
  create_login_profile = false
  create_inline_policy = true

  inline_policy_permissions = {
    sqs = {
      actions   = ["sqs:GetQueueUrl", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      resources = [dependency.sqs.outputs.queue_arn]
    }
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-user?version=6.5.0"
}
