output "fields" {
  description = "All fields from the 1Password item as a map"
  value = merge(
    {
      credential = data.onepassword_item.this.credential
      username   = data.onepassword_item.this.username
      password   = data.onepassword_item.this.password
      note_value = data.onepassword_item.this.note_value
    },
    { for field in flatten([for section in data.onepassword_item.this.section : section.field]) : field.label => field.value }
  )
  sensitive = true
}
