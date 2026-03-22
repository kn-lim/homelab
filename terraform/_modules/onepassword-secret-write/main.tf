resource "onepassword_item" "default" {
  vault    = data.onepassword_vault.default.uuid
  title    = var.secret_name
  category = "login"

  section {
    label = "Details"

    field {
      label = var.field_name
      type  = "concealed"
      value = var.value
    }
  }
}
