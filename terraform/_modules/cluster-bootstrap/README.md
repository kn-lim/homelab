# cluster-bootstrap

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret_v1.token](https://registry.terraform.io/providers/hashicorp/kubernetes/3.0.1/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to create the Kubernetes resources in. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | Token value from 1Password. | `string` | n/a | yes |
| <a name="input_token_secret_name"></a> [token\_secret\_name](#input\_token\_secret\_name) | Name of Kubernetes Secret containing the token. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
