resource "grafana_folder" "dashboards" {
  for_each = var.dashboards

  title = each.key
  uid   = each.value.uid
}

data "http" "dashboard_json" {
  for_each = local.dashboards_flat

  url = each.value.url

  request_headers = {
    Accept = "application/json"
  }
}

resource "grafana_dashboard" "dashboards" {
  for_each = local.dashboards_flat

  folder      = grafana_folder.dashboards[each.value.folder_name].uid
  config_json = data.http.dashboard_json[each.key].response_body
}

resource "grafana_data_source" "prometheus" {
  for_each = var.prometheus_sources

  type       = "prometheus"
  name       = "prometheus-${each.key}"
  uid        = each.value.uid
  url        = each.value.url
  is_default = each.value.is_default
}
