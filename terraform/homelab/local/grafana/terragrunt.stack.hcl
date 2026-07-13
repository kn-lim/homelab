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
      # https://grafana.com/grafana/dashboards/1860-node-exporter-full/
      node = {
        urls = [
          "https://grafana.com/api/dashboards/1860/revisions/latest/download",
        ]
      }
      # https://grafana.com/grafana/dashboards/17346-traefik-official-standalone-dashboard/
      traefik = {
        urls = [
          "https://grafana.com/api/dashboards/17346/revisions/latest/download",
        ]
      }
      # https://github.com/adinhodovic/argo-cd-mixin
      argocd = {
        urls = [
          "https://raw.githubusercontent.com/adinhodovic/argo-cd-mixin/main/dashboards_out/argo-cd-application-overview.json",
          "https://raw.githubusercontent.com/adinhodovic/argo-cd-mixin/main/dashboards_out/argo-cd-notifications-overview.json",
          "https://raw.githubusercontent.com/adinhodovic/argo-cd-mixin/main/dashboards_out/argo-cd-operational-overview.json",
        ]
      }
      cloudnative-pg = {
        urls = [
          "https://raw.githubusercontent.com/cloudnative-pg/grafana-dashboards/main/charts/cluster/grafana-dashboard.json",
        ]
      }
      # https://grafana.com/grafana/dashboards/20842-cert-manager-kubernetes/
      cert-manager = {
        urls = [
          "https://grafana.com/api/dashboards/20842/revisions/latest/download",
        ]
      }
      # https://grafana.com/grafana/dashboards/12239-nvidia-dcgm-exporter-dashboard/
      gpu = {
        urls = [
          "https://grafana.com/api/dashboards/12239/revisions/latest/download",
        ]
      }
      # https://grafana.com/grafana/dashboards/763-redis-dashboard-for-prometheus-redis-exporter-1-x/
      valkey = {
        urls = [
          "https://grafana.com/api/dashboards/763/revisions/latest/download",
        ]
      }
      # https://github.com/cilium/cilium
      cilium = {
        urls = [
          "https://raw.githubusercontent.com/cilium/cilium/main/install/kubernetes/cilium/files/cilium-agent/dashboards/cilium-dashboard.json",
          "https://raw.githubusercontent.com/cilium/cilium/main/install/kubernetes/cilium/files/cilium-operator/dashboards/cilium-operator-dashboard.json",
          "https://raw.githubusercontent.com/cilium/cilium/main/install/kubernetes/cilium/files/hubble/dashboards/hubble-dashboard.json",
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
    secret_name = "grafana"
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
          webhook_url = "https://discord.com/api/webhooks/mock"
        }
      }

      mock_outputs_allowed_terraform_commands = ["init", "import", "validate", "plan"]
    }

    inputs = {
      discord_webhook_url = dependency.onepassword-secret-read.outputs.fields["webhook_url"]
    }
  }
}
