resource "grafana_contact_point" "discord" {
  name = "discord"

  discord {
    url = var.discord_webhook_url
  }
}

resource "grafana_notification_policy" "root" {
  contact_point = grafana_contact_point.discord.name
  group_by      = ["grafana_folder", "alertname"]

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"
}
