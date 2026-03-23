resource "onepassword_item" "default" {
  vault    = data.onepassword_vault.default.uuid
  title    = var.secret_name
  category = "login"

  section_map = {
    "Details" = {
      field_map = {
        for k, v in var.fields : k => {
          type  = "CONCEALED"
          value = v
        }
      }
    }
  }
}
