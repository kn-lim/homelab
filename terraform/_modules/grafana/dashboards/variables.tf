variable "dashboards" {
  description = "Map of dashboard folders to their configurations."
  type = map(object({
    uid  = optional(string, null)
    urls = set(string)
  }))
}

variable "datasource_uid" {
  description = "Datasource UID substituted for \"$${DS_PROMETHEUS}\" template inputs in imported dashboards."
  type        = string
}
