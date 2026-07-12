# grafana/alerting

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | 4.40.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 4.40.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [grafana_contact_point.discord](https://registry.terraform.io/providers/grafana/grafana/4.40.1/docs/resources/contact_point) | resource |
| [grafana_notification_policy.root](https://registry.terraform.io/providers/grafana/grafana/4.40.1/docs/resources/notification_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_discord_webhook_url"></a> [discord\_webhook\_url](#input\_discord\_webhook\_url) | Discord webhook URL for the alerting contact point. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
