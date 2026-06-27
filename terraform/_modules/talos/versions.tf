terraform {
  required_version = ">= 1.15"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }
}
