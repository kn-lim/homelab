locals {}

inputs = {
  vault_name  = values.vault_name
  secret_name = values.secret_name
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${find_in_parent_folders("_modules/onepassword-secret")}"
}
