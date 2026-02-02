data "cloudflare_zone" "default" {
  filter = {
    name = var.zone
  }
}
