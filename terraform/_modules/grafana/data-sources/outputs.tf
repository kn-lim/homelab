output "uids" {
  description = "Map of Prometheus data source keys to their Grafana UIDs."
  value       = { for key, ds in grafana_data_source.prometheus : key => ds.uid }
}
