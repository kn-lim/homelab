output "kubeconfig" {
  description = "The kubeconfig for accessing the Kubernetes cluster"
  value       = talos_cluster_kubeconfig.default.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "The talosconfig for accessing the Talos cluster"
  value       = data.talos_client_configuration.default.talos_config
  sensitive   = true
}
