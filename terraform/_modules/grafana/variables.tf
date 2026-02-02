variable "dashboards" {
  description = "Map of dashboard folders to their configurations."
  type = map(object({
    uid  = optional(string, null)
    urls = set(string)
  }))
}

variable "prometheus_sources" {
  description = "Map of Prometheus data sources keyed by cluster name."
  type = map(object({
    url        = string
    uid        = optional(string, null)
    is_default = optional(bool, false)
  }))
}
