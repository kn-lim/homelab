# cloudflare-records

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 5.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.name](https://registry.terraform.io/providers/cloudflare/cloudflare/5.17.0/docs/resources/dns_record) | resource |
| [cloudflare_zone.default](https://registry.terraform.io/providers/cloudflare/cloudflare/5.17.0/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_records"></a> [records](#input\_records) | Map of Cloudflare DNS Records | <pre>map(object({<br/>    comment = optional(string, "")<br/>    content = string<br/>    proxied = optional(bool, false)<br/>    ttl     = optional(number, 1)<br/>    type    = optional(string, "A")<br/>    tags    = optional(set(string), [""])<br/>  }))</pre> | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Name of the Cloudflare Zone | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
