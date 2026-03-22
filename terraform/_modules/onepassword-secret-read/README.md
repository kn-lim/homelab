# onepassword-secret

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14 |
| <a name="requirement_onepassword"></a> [onepassword](#requirement\_onepassword) | 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_onepassword"></a> [onepassword](#provider\_onepassword) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [onepassword_item.default](https://registry.terraform.io/providers/1Password/onepassword/3.2.1/docs/data-sources/item) | data source |
| [onepassword_vault.default](https://registry.terraform.io/providers/1Password/onepassword/3.2.1/docs/data-sources/vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the 1Password item | `string` | n/a | yes |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Name of the 1Password vault | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fields"></a> [fields](#output\_fields) | All fields from the 1Password item as a map |
<!-- END_TF_DOCS -->
