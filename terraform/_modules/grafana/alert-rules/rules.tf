locals {
  rule_groups = {
    node = [
      {
        name      = "NodeCPUHigh"
        expr      = "1 - avg(rate(node_cpu_seconds_total{mode=\"idle\"}[10m]))"
        op        = "gt"
        threshold = 0.9
        for       = "15m"
        severity  = "warning"
        summary   = "Node CPU usage above 90% for 15 minutes."
      },
      {
        name      = "NodeMemoryHigh"
        expr      = "1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes"
        op        = "gt"
        threshold = 0.9
        for       = "10m"
        severity  = "warning"
        summary   = "Node memory usage above 90% for 10 minutes."
      },
      {
        name      = "NodeFilesystemAlmostFull"
        expr      = "max by (mountpoint) (1 - node_filesystem_avail_bytes{fstype!~\"tmpfs|ramfs\"} / node_filesystem_size_bytes)"
        op        = "gt"
        threshold = 0.85
        for       = "15m"
        severity  = "warning"
        summary   = "Node filesystem more than 85% full."
      },
      {
        name          = "NodeNotReady"
        expr          = "min(kube_node_status_condition{condition=\"Ready\", status=\"true\"})"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "A node is not Ready."
        no_data_state = "Alerting"
      },
    ]

    control-plane = [
      {
        name          = "ApiServerDown"
        expr          = "min(up{job=\"apiserver\"})"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "Kubernetes API server target is down."
        no_data_state = "Alerting"
      },
      {
        name          = "EtcdDown"
        expr          = "min(up{job=\"etcd\"})"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "etcd metrics target is down."
        no_data_state = "Alerting"
      },
      {
        name      = "ApiServerHighLatency"
        expr      = "histogram_quantile(0.99, sum by (le) (rate(apiserver_request_duration_seconds_bucket{verb!~\"WATCH|CONNECT\"}[10m])))"
        op        = "gt"
        threshold = 1
        for       = "15m"
        severity  = "warning"
        summary   = "API server p99 request latency above 1s."
      },
    ]

    workloads = [
      {
        name      = "PodCrashLooping"
        expr      = "sum by (namespace, pod) (increase(kube_pod_container_status_restarts_total[1h]))"
        op        = "gt"
        threshold = 3
        for       = "5m"
        severity  = "warning"
        summary   = "Pod restarted more than 3 times in the last hour."
      },
      {
        name      = "DeploymentReplicasMismatch"
        expr      = "max by (namespace, deployment) (kube_deployment_spec_replicas - kube_deployment_status_replicas_available)"
        op        = "gt"
        threshold = 0
        for       = "15m"
        severity  = "warning"
        summary   = "Deployment has unavailable replicas for 15 minutes."
      },
      {
        name      = "PVCAlmostFull"
        expr      = "max by (namespace, persistentvolumeclaim) (kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes)"
        op        = "gt"
        threshold = 0.85
        for       = "15m"
        severity  = "warning"
        summary   = "PersistentVolumeClaim more than 85% full."
      },
    ]

    platform = [
      {
        # Filtered query: empty result (NoData) means everything is healthy
        name          = "ArgoAppNotHealthy"
        expr          = "sum by (name) (argocd_app_info{health_status!=\"Healthy\"})"
        op            = "gt"
        threshold     = 0
        for           = "15m"
        severity      = "warning"
        summary       = "ArgoCD application is not Healthy."
        no_data_state = "OK"
      },
      {
        # Filtered query: empty result (NoData) means everything is healthy
        name          = "ArgoAppOutOfSync"
        expr          = "sum by (name) (argocd_app_info{sync_status!=\"Synced\"})"
        op            = "gt"
        threshold     = 0
        for           = "1h"
        severity      = "warning"
        summary       = "ArgoCD application has been OutOfSync for 1 hour."
        no_data_state = "OK"
      },
      {
        name      = "CertificateExpiringSoon"
        expr      = "min by (namespace, name) ((certmanager_certificate_expiration_timestamp_seconds - time()) / 86400)"
        op        = "lt"
        threshold = 14
        for       = "1h"
        severity  = "warning"
        summary   = "Certificate expires in less than 14 days."
      },
      {
        # Component-down check: a vanished target yields NoData, so alert on it
        name          = "CNPGInstanceDown"
        expr          = "min(cnpg_collector_up)"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "CloudNativePG instance metrics collector is down."
        no_data_state = "Alerting"
      },
      {
        name      = "ExternalSecretSyncFailing"
        expr      = "sum by (namespace, name) (externalsecret_status_condition{condition=\"Ready\", status=\"False\"})"
        op        = "gt"
        threshold = 0
        for       = "15m"
        severity  = "warning"
        summary   = "ExternalSecret is failing to sync."
      },
      {
        # No 5xx samples yet (or no traffic) renders NoData: that is healthy
        name          = "TraefikHigh5xxRate"
        expr          = "sum(rate(traefik_service_requests_total{code=~\"5..\"}[5m])) / sum(rate(traefik_service_requests_total[5m]))"
        op            = "gt"
        threshold     = 0.05
        for           = "10m"
        severity      = "warning"
        summary       = "More than 5% of Traefik requests are 5xx."
        no_data_state = "OK"
      },
    ]

    gpu = [
      {
        name      = "GPUTemperatureHigh"
        expr      = "max(DCGM_FI_DEV_GPU_TEMP)"
        op        = "gt"
        threshold = 85
        for       = "10m"
        severity  = "warning"
        summary   = "GPU temperature above 85C for 10 minutes."
      },
      {
        name      = "GPUMemoryAlmostFull"
        expr      = "max(DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE))"
        op        = "gt"
        threshold = 0.95
        for       = "15m"
        severity  = "warning"
        summary   = "GPU memory more than 95% used for 15 minutes."
      },
    ]

    meta = [
      {
        name           = "MetricsPipelineDown"
        expr           = "min(up{job=\"prometheus-server\"})"
        op             = "lt"
        threshold      = 1
        for            = "5m"
        severity       = "critical"
        summary        = "Prometheus is down or unreachable — the metrics pipeline is broken."
        no_data_state  = "Alerting"
        exec_err_state = "Alerting"
      },
      {
        name      = "AlloyRemoteWriteFailing"
        expr      = "sum(rate(prometheus_remote_storage_samples_failed_total[10m]))"
        op        = "gt"
        threshold = 0
        for       = "10m"
        severity  = "critical"
        summary   = "Alloy is failing to remote_write samples to Prometheus."
      },
      {
        name          = "CriticalScrapeTargetsAbsent"
        expr          = "(absent(up{job=\"kubelet\"}) or absent(up{job=\"node-exporter\"}) or absent(up{job=\"apiserver\"})) * 1"
        op            = "gt"
        threshold     = 0
        for           = "15m"
        severity      = "critical"
        summary       = "A critical scrape target (kubelet / node-exporter / apiserver) is absent."
        no_data_state = "OK"
      },
      {
        name      = "ScrapeTargetDown"
        expr      = "min by (job) (up)"
        op        = "lt"
        threshold = 1
        for       = "15m"
        severity  = "warning"
        summary   = "A scrape target has been down for 15 minutes."
      },
    ]
  }
}
