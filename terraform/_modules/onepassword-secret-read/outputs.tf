output "fields" {
  description = "All fields from the 1Password item as a map. If two sections have a field with the same label, the last one wins. Use sections for those fields."
  value = merge(
    {
      credential = data.onepassword_item.default.credential
      username   = data.onepassword_item.default.username
      password   = data.onepassword_item.default.password
      note_value = data.onepassword_item.default.note_value
    },
    [for section in data.onepassword_item.default.section : { for field in section.field : field.label => field.value }]...
  )
  sensitive = true
}

output "sections" {
  description = "The fields of each labeled section of the 1Password item, as a map of section label to a map of field label to value"
  value = {
    for label, section in data.onepassword_item.default.section_map :
    label => { for name, field in section.field_map : name => field.value }
    if label != ""
  }
  sensitive = true
}
