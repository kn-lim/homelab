terraform {
  required_version = ">= 1.14"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.31.3"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}
