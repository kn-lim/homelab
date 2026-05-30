terraform {
  required_version = ">= 1.14"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.36.2"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }
  }
}
