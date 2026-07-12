unit "data-sources" {
  source = "${find_in_parent_folders("_units/grafana/data-sources")}"

  path = "data-sources"

  values = {
    prometheus_sources = {
      homelab = {
        uid        = "prometheus-homelab"
        url        = "http://prometheus-server.prometheus.svc.cluster.local:80"
        is_default = true
      }
    }
  }
}

unit "dashboards" {
  source = "${find_in_parent_folders("_units/grafana/dashboards")}"

  path = "dashboards"

  autoinclude {
    dependency "data-sources" {
      config_path = unit.data-sources.path

      mock_outputs = {
        uids = {
          homelab = "prometheus-homelab"
        }
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      datasource_uid = dependency.data-sources.outputs.uids["homelab"]
    }
  }

  values = {
    dashboards = {
      # https://github.com/dotdc/grafana-dashboards-kubernetes
      kubernetes = {
        urls = [
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-addons-prometheus.json",
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-api-server.json",
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json",
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json",
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json",
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-nodes.json",
          "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json",
        ]
      }
    }
  }
}

unit "onepassword-secret-read" {
  source = "${find_in_parent_folders("_units/onepassword-secret-read")}"

  path = "onepassword-secret-read"

  values = {
    vault_name  = "Homelab"
    secret_name = "grafana-discord-webhook"
  }
}

unit "alerting" {
  source = "${find_in_parent_folders("_units/grafana/alerting")}"

  path = "alerting"

  autoinclude {
    dependency "onepassword-secret-read" {
      config_path = unit.onepassword-secret-read.path

      mock_outputs = {
        fields = {
          credential = "https://discord.com/api/webhooks/mock"
        }
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      discord_webhook_url = dependency.onepassword-secret-read.outputs.fields["credential"]
    }
  }
}
