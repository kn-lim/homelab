dependency "sqs" {
  config_path = "../sqs"
}

inputs = {
  vault_name  = values.vault_name
  secret_name = values.secret_name
  field_name  = values.field_name
  value       = dependency.sqs.outputs.queue_url
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/onepassword-secret-write")}"
}
