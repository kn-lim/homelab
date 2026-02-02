terraform {
  required_version = ">= 1.14"

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.1.2"
    }
  }
}
