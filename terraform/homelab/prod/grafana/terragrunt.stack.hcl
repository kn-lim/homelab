unit "grafana" {
  source = "${find_in_parent_folders("_units/grafana")}"

  path = "grafana"

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

    prometheus_sources = {
      homelab = {
        url        = "http://prometheus-server.monitoring.svc.cluster.local:80"
        is_default = true
      }
    }
  }
}
