terraform {
  required_version = ">= 1.14"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.25.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}
