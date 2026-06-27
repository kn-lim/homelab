terraform {
  required_version = ">= 1.15"

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}
