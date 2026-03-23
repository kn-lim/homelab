# TODO: These dependencies need to exist due to lack of support for units passing outputs directly between each other in a stack.
#       https://github.com/gruntwork-io/terragrunt/issues/4067
#       https://github.com/gruntwork-io/terragrunt/issues/5663
dependency "sqs" {
  config_path = "../sqs"
}

dependency "iam_user" {
  config_path = "../iam-user"
}

inputs = {
  vault_name  = values.vault_name
  secret_name = values.secret_name
  fields = {
    sqs_url               = dependency.sqs.outputs.queue_url
    aws_access_key_id     = dependency.iam_user.outputs.access_key_id
    aws_secret_access_key = dependency.iam_user.outputs.access_key_secret
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/onepassword-secret-write")}"
}
