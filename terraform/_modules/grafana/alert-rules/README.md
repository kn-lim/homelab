# grafana/alert-rules

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 4.45.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 4.45.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [grafana_folder.alerts](https://registry.terraform.io/providers/grafana/grafana/4.45.1/docs/resources/folder) | resource |
| [grafana_rule_group.groups](https://registry.terraform.io/providers/grafana/grafana/4.45.1/docs/resources/rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_datasource_uid"></a> [datasource\_uid](#input\_datasource\_uid) | UID of the Prometheus data source that alert rule queries run against. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
