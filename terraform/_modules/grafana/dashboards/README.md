# grafana/dashboards

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 4.43.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 4.40.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [grafana_dashboard.dashboards](https://registry.terraform.io/providers/grafana/grafana/4.43.0/docs/resources/dashboard) | resource |
| [grafana_folder.dashboards](https://registry.terraform.io/providers/grafana/grafana/4.43.0/docs/resources/folder) | resource |
| [http_http.dashboard_json](https://registry.terraform.io/providers/hashicorp/http/3.6.0/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dashboards"></a> [dashboards](#input\_dashboards) | Map of dashboard folders to their configurations. | <pre>map(object({<br/>    uid  = optional(string, null)<br/>    urls = set(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_datasource_uid"></a> [datasource\_uid](#input\_datasource\_uid) | Datasource UID substituted for "${DS\_PROMETHEUS}" template inputs in imported dashboards. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
