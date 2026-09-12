terraform {
  required_version = ">= 1.15"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.46.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.6.1"
    }
  }
}
