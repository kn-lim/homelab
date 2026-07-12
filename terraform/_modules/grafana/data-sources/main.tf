resource "grafana_data_source" "prometheus" {
  for_each = var.prometheus_sources

  type       = "prometheus"
  name       = "prometheus-${each.key}"
  uid        = each.value.uid
  url        = each.value.url
  is_default = each.value.is_default
}
