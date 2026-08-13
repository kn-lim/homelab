# tailscale/acl

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
| [tailscale_acl.default](https://registry.terraform.io/providers/tailscale/tailscale/0.29.2/docs/resources/acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acl"></a> [acl](#input\_acl) | The tailnet policy file as a JSON or HuJSON string | `string` | n/a | yes |
| <a name="input_overwrite_existing_content"></a> [overwrite\_existing\_content](#input\_overwrite\_existing\_content) | Whether to overwrite the existing policy file without importing it into state first | `bool` | `true` | no |
| <a name="input_reset_acl_on_destroy"></a> [reset\_acl\_on\_destroy](#input\_reset\_acl\_on\_destroy) | Whether to reset the policy file to the Tailscale default when this resource is destroyed | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
