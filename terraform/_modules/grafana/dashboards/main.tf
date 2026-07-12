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

  folder = grafana_folder.dashboards[each.value.folder_name].uid
  config_json = replace(
    data.http.dashboard_json[each.key].response_body,
    "$${DS_PROMETHEUS}",
    var.datasource_uid,
  )
}
