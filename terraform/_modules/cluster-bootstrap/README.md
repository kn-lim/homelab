# cluster-bootstrap

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.2.1 |
| <a name="requirement_onepassword"></a> [onepassword](#requirement\_onepassword) | 3.3.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.2.1 |
| <a name="provider_onepassword"></a> [onepassword](#provider\_onepassword) | 3.3.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_cluster_role_binding_v1.argocd_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/3.2.1/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_secret_v1.argocd_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/3.2.1/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.token](https://registry.terraform.io/providers/hashicorp/kubernetes/3.2.1/docs/resources/secret_v1) | resource |
| [kubernetes_service_account_v1.argocd_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/3.2.1/docs/resources/service_account_v1) | resource |
| [onepassword_item.argocd_registration](https://registry.terraform.io/providers/1Password/onepassword/3.3.1/docs/resources/item) | resource |
| [onepassword_vault.argocd_registration](https://registry.terraform.io/providers/1Password/onepassword/3.3.1/docs/data-sources/vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argocd_registration"></a> [argocd\_registration](#input\_argocd\_registration) | Register this cluster with a remote ArgoCD hub by storing manager credentials in 1Password. Null disables registration. | <pre>object({<br/>    cluster_endpoint = string<br/>    vault_name       = string<br/>    secret_name      = string<br/>  })</pre> | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to create the Kubernetes resources in. | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | Token value from 1Password. | `string` | n/a | yes |
| <a name="input_token_secret_name"></a> [token\_secret\_name](#input\_token\_secret\_name) | Name of Kubernetes Secret containing the token. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
