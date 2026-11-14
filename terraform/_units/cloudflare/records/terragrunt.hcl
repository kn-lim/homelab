locals {}

inputs = {
  records = values.records
  zone    = values.zone
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/kn-lim/homelab.git//terraform/_modules/cloudflare/records?ref=main"
}
