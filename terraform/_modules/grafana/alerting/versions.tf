terraform {
  required_version = ">= 1.15"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.43.0"
    }
  }
}
