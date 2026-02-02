resource "cloudflare_dns_record" "name" {
  for_each = var.records

  zone_id = data.cloudflare_zone.default.zone_id
  name    = each.key
  ttl     = each.value.ttl
  type    = each.value.type
  comment = each.value.comment
  content = each.value.content
  proxied = each.value.proxied
}
