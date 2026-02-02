locals {}

# TODO: This needs to exist due to lack of support for units passing outputs directly between each other in a stack.
#       https://github.com/gruntwork-io/terragrunt/issues/4067
dependencies {
  paths = ["../talos", "../onepassword-secret"]
}

dependency "onepassword_secret" {
  config_path = "../onepassword-secret"

  mock_outputs = {
    fields = {
      credential = "mock-credential"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  namespace         = values.namespace
  token             = dependency.onepassword_secret.outputs.fields["credential"]
  token_secret_name = values.token_secret_name
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/cluster-bootstrap")}"
}
