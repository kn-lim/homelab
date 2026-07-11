resource "tailscale_dns_configuration" "default" {
  magic_dns          = var.magic_dns
  override_local_dns = var.override_local_dns

  dynamic "nameservers" {
    for_each = var.nameservers
    content {
      address            = nameservers.value
      use_with_exit_node = var.use_with_exit_node
    }
  }
}
