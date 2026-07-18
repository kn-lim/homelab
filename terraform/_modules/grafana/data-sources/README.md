# grafana/data-sources

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 4.41.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 4.40.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [grafana_data_source.prometheus](https://registry.terraform.io/providers/grafana/grafana/4.41.0/docs/resources/data_source) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_prometheus_sources"></a> [prometheus\_sources](#input\_prometheus\_sources) | Map of Prometheus data sources keyed by cluster name. | <pre>map(object({<br/>    url        = string<br/>    uid        = optional(string, null)<br/>    is_default = optional(bool, false)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_uids"></a> [uids](#output\_uids) | Map of Prometheus data source keys to their Grafana UIDs. |
<!-- END_TF_DOCS -->
