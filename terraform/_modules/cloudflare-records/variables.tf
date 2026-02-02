# Required Variables

variable "records" {
  description = "Map of Cloudflare DNS Records"
  type = map(object({
    comment = optional(string, "")
    content = string
    proxied = optional(bool, false)
    ttl     = optional(number, 1)
    type    = optional(string, "A")
    tags    = optional(set(string), [""])
  }))
}

variable "zone" {
  description = "Name of the Cloudflare Zone"
  type        = string
}
