inputs = {
  acl = file("${get_repo_root()}/${values.policy_file}")
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/kn-lim/homelab.git//terraform/_modules/tailscale/acl?ref=main"
}
