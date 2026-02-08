# talos

- `terragrunt stack output --filter="talos" --json | jq -r '.talos.kubeconfig' > kubeconfig`
- `terragrunt stack output --filter="talos" --json | jq -r '.talos.talosconfig' > talosconfig`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.10.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.10.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [talos_cluster_kubeconfig.default](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/cluster_kubeconfig) | resource |
| [talos_machine_bootstrap.default](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.default](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.default](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/data-sources/client_configuration) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | The endpoint for the Talos cluster | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | A name to provide for the Talos cluster | `string` | n/a | yes |
| <a name="input_dns_server"></a> [dns\_server](#input\_dns\_server) | DNS server | `string` | n/a | yes |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | Network gateway | `string` | n/a | yes |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface name for Talos nodes | `string` | `"ens18"` | no |
| <a name="input_node_data"></a> [node\_data](#input\_node\_data) | A map of node data | <pre>object({<br/>    controlplanes = map(object({<br/>      install_disk = optional(string, "/dev/sda")<br/>      hostname     = optional(string, "")<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_node_subnet"></a> [node\_subnet](#input\_node\_subnet) | Node subnet for kubelet nodeIP validation | `string` | n/a | yes |
| <a name="input_pod_subnet"></a> [pod\_subnet](#input\_pod\_subnet) | Pod subnet for Kubernetes pods | `string` | n/a | yes |
| <a name="input_service_subnet"></a> [service\_subnet](#input\_service\_subnet) | Service subnet for Kubernetes services | `string` | n/a | yes |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version for machine configuration schema | `string` | `"v1.12.3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | The kubeconfig for accessing the Kubernetes cluster |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | The talosconfig for accessing the Talos cluster |
<!-- END_TF_DOCS -->
