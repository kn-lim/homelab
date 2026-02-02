data "onepassword_vault" "this" {
  name = var.vault_name
}

data "onepassword_item" "this" {
  vault = data.onepassword_vault.this.uuid
  title = var.secret_name
}
