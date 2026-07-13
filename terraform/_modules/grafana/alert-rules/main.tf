resource "grafana_folder" "alerts" {
  title = "Alerts"
  uid   = "alerts"
}

resource "grafana_rule_group" "groups" {
  for_each = local.rule_groups

  name             = each.key
  folder_uid       = grafana_folder.alerts.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = each.value

    content {
      name           = rule.value.name
      condition      = "C"
      for            = rule.value.for
      no_data_state  = lookup(rule.value, "no_data_state", "NoData")
      exec_err_state = lookup(rule.value, "exec_err_state", "Error")

      annotations = {
        summary = rule.value.summary
      }

      labels = {
        severity = rule.value.severity
      }

      data {
        ref_id         = "A"
        datasource_uid = var.datasource_uid

        relative_time_range {
          from = 600
          to   = 0
        }

        model = jsonencode({
          refId   = "A"
          expr    = rule.value.expr
          instant = true
        })
      }

      data {
        ref_id         = "C"
        datasource_uid = "__expr__"

        relative_time_range {
          from = 0
          to   = 0
        }

        model = jsonencode({
          refId      = "C"
          type       = "threshold"
          expression = "A"
          conditions = [
            {
              evaluator = {
                type   = rule.value.op
                params = [rule.value.threshold]
              }
            }
          ]
        })
      }
    }
  }
}
