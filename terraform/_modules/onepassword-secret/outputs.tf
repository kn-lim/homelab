output "fields" {
  description = "All fields from the 1Password item as a map"
  value = merge(
    {
      credential = data.onepassword_item.default.credential
      username   = data.onepassword_item.default.username
      password   = data.onepassword_item.default.password
      note_value = data.onepassword_item.default.note_value
    },
    { for field in flatten([for section in data.onepassword_item.default.section : section.field]) : field.label => field.value }
  )
  sensitive = true
}
