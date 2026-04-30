terraform {
  required_version = ">= 1.14"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }
}
