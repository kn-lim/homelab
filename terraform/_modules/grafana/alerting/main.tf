resource "grafana_message_template" "discord" {
  name = "discord"

  template = <<-EOT
    {{ define "discord.title" -}}
    {{ if gt (len .Alerts.Firing) 0 }}Alert Firing{{ if gt (len .Alerts.Firing) 1 }} ({{ len .Alerts.Firing }}){{ end }}{{ else }}Alert Resolved{{ end }}
    {{- end }}

    {{ define "discord.alert" -}}
    **Alert:** {{ .Labels.alertname }}
    **Severity:** {{ or .Labels.severity "n/a" }}
    {{- with .Labels.namespace }}
    **Namespace:** {{ . }}
    {{- end }}
    {{- with .Labels.pod }}
    **Pod:** {{ . }}
    {{- end }}
    {{- with .Annotations.summary }}
    **Summary:** {{ . }}
    {{- end }}
    [View]({{ .GeneratorURL }}) · [Silence]({{ .SilenceURL }})
    {{- end }}

    {{ define "discord.message" -}}
    {{ range .Alerts.Firing }}{{ template "discord.alert" . }}

    {{ end }}
    {{- if .Alerts.Resolved }}**Resolved:**
    {{ range .Alerts.Resolved }}{{ .Labels.alertname }}{{ with .Labels.pod }} ({{ . }}){{ end }}
    {{ end }}
    {{- end }}
    {{- end }}
  EOT
}

resource "grafana_contact_point" "discord" {
  name = "discord"

  discord {
    url     = var.discord_webhook_url
    title   = "{{ template \"discord.title\" . }}"
    message = "{{ template \"discord.message\" . }}"
  }

  depends_on = [grafana_message_template.discord]
}

resource "grafana_notification_policy" "root" {
  contact_point = grafana_contact_point.discord.name
  group_by      = ["grafana_folder", "alertname"]

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"
}
