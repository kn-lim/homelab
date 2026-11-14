inputs = {
  nameservers        = values.nameservers
  use_with_exit_node = values.use_with_exit_node
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/kn-lim/homelab.git//terraform/_modules/tailscale/dns?ref=main"
}
