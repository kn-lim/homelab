data "onepassword_vault" "default" {
  name = var.vault_name
}

data "onepassword_item" "default" {
  vault = data.onepassword_vault.default.uuid
  title = var.secret_name
}
