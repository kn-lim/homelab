# tailscale/dns

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | 0.29.2 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.29.2 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [tailscale_dns_configuration.default](https://registry.terraform.io/providers/tailscale/tailscale/0.29.2/docs/resources/dns_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_magic_dns"></a> [magic\_dns](#input\_magic\_dns) | Whether MagicDNS is enabled for the tailnet | `bool` | `true` | no |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | List of global nameserver IP addresses for the tailnet | `list(string)` | n/a | yes |
| <a name="input_override_local_dns"></a> [override\_local\_dns](#input\_override\_local\_dns) | Whether devices ignore their local DNS and always use the global nameservers | `bool` | `true` | no |
| <a name="input_use_with_exit_node"></a> [use\_with\_exit\_node](#input\_use\_with\_exit\_node) | Whether devices keep using the global nameservers while an exit node is active (requires Tailscale v1.88.1+) | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
