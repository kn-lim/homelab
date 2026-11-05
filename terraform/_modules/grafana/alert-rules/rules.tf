locals {
  rule_groups = {
    node = [
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
        expr      = "max by (cluster, mountpoint) (1 - node_filesystem_avail_bytes{fstype!~\"tmpfs|ramfs\"} / node_filesystem_size_bytes)"
        op        = "gt"
        threshold = 0.85
        for       = "15m"
        severity  = "warning"
        summary   = "Node filesystem more than 85% full."
      },
      {
        name          = "NodeNotReady"
        expr          = "min by (cluster) (kube_node_status_condition{condition=\"Ready\", status=\"true\"})"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "A node is not Ready."
        no_data_state = "Alerting"
      },
      {
        name          = "NodePressure"
        expr          = "max by (cluster, condition) (kube_node_status_condition{condition=~\"DiskPressure|MemoryPressure|PIDPressure\", status=\"true\"})"
        op            = "gt"
        threshold     = 0
        for           = "5m"
        severity      = "warning"
        summary       = "A node reports disk, memory, or PID pressure."
        no_data_state = "OK"
      },
    ]

    control-plane = [
      {
        name          = "ApiServerDown"
        expr          = "min by (cluster) (up{job=\"apiserver\"})"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "Kubernetes API server target is down."
        no_data_state = "Alerting"
      },
      {
        name          = "EtcdDown"
        expr          = "min by (cluster) (up{job=\"etcd\"})"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "etcd metrics target is down."
        no_data_state = "Alerting"
      },
      {
        name      = "ApiServerHighLatency"
        expr      = "histogram_quantile(0.99, sum by (cluster, le) (rate(apiserver_request_duration_seconds_bucket{verb!~\"WATCH|CONNECT\"}[10m])))"
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
        expr      = "sum by (cluster, namespace, pod) (increase(kube_pod_container_status_restarts_total[1h]))"
        op        = "gt"
        threshold = 3
        for       = "5m"
        severity  = "warning"
        summary   = "Pod restarted more than 3 times in the last hour."
      },
      {
        name      = "DeploymentReplicasMismatch"
        expr      = "max by (cluster, namespace, deployment) (kube_deployment_spec_replicas - kube_deployment_status_replicas_available)"
        op        = "gt"
        threshold = 0
        for       = "15m"
        severity  = "warning"
        summary   = "Deployment has unavailable replicas for 15 minutes."
      },
      {
        name          = "StatefulSetReplicasMismatch"
        expr          = "max by (cluster, namespace, statefulset) (kube_statefulset_status_replicas - kube_statefulset_status_replicas_ready)"
        op            = "gt"
        threshold     = 0
        for           = "15m"
        severity      = "warning"
        summary       = "StatefulSet has replicas that are not ready for 15 minutes."
        no_data_state = "OK"
      },
      {
        name          = "DaemonSetUnavailable"
        expr          = "max by (cluster, namespace, daemonset) (kube_daemonset_status_number_unavailable)"
        op            = "gt"
        threshold     = 0
        for           = "15m"
        severity      = "warning"
        summary       = "DaemonSet has unavailable pods for 15 minutes."
        no_data_state = "OK"
      },
      {
        # The Failed condition, not the failed pod count: a Job that succeeds on retry keeps failed pods until its TTL
        name          = "KubeJobFailed"
        expr          = "max by (cluster, namespace, job_name) (kube_job_failed{condition=\"true\"})"
        op            = "gt"
        threshold     = 0
        for           = "5m"
        severity      = "warning"
        summary       = "A Job has failed."
        no_data_state = "OK"
      },
      {
        name      = "PVCAlmostFull"
        expr      = "max by (cluster, namespace, persistentvolumeclaim) (kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes)"
        op        = "gt"
        threshold = 0.85
        for       = "15m"
        severity  = "warning"
        summary   = "PersistentVolumeClaim more than 85% full."
      },
    ]

    platform = [
      {
        name      = "CertificateExpiringSoon"
        expr      = "min by (cluster, namespace, name) ((certmanager_certificate_expiration_timestamp_seconds - time()) / 86400)"
        op        = "lt"
        threshold = 14
        for       = "1h"
        severity  = "warning"
        summary   = "Certificate expires in less than 14 days."
      },
      {
        # Component-down check: a vanished target yields NoData, so alert on it
        name          = "CNPGInstanceDown"
        expr          = "min by (cluster) (cnpg_collector_up)"
        op            = "lt"
        threshold     = 1
        for           = "5m"
        severity      = "critical"
        summary       = "CloudNativePG instance metrics collector is down."
        no_data_state = "Alerting"
      },
      {
        name          = "ExternalSecretSyncFailing"
        expr          = "sum by (cluster, namespace, name) (externalsecret_status_condition{condition=\"Ready\", status=\"False\"})"
        op            = "gt"
        threshold     = 0
        for           = "15m"
        severity      = "warning"
        summary       = "ExternalSecret is failing to sync."
        no_data_state = "OK"
      },
      {
        # 50 hours allows one missed 03:00 backup while a machine is off, but not two
        name          = "VeleroBackupMissing"
        expr          = "time() - max by (cluster, schedule) (velero_backup_last_successful_timestamp{schedule!=\"\"})"
        op            = "gt"
        threshold     = 180000
        for           = "15m"
        severity      = "warning"
        summary       = "No successful Velero backup in 50 hours."
        no_data_state = "OK"
      },
      {
        # Velero creates the success timestamp only after a success, so after a restart only the failure counters show a failed backup
        name          = "VeleroBackupFailed"
        expr          = "sum by (cluster, schedule) (increase(velero_backup_failure_total{schedule!=\"\"}[26h]) + increase(velero_backup_partial_failure_total{schedule!=\"\"}[26h]))"
        op            = "gt"
        threshold     = 0
        for           = "5m"
        severity      = "warning"
        summary       = "A Velero backup failed or partly failed in the last 26 hours."
        no_data_state = "OK"
      },
      {
        # No 5xx samples yet (or no traffic) renders NoData: that is healthy
        # The prefix filter drops the admin, stats, and readiness listeners of the Envoy proxy
        name          = "EnvoyHigh5xxRate"
        expr          = "sum by (cluster) (rate(envoy_http_downstream_rq_xx{envoy_response_code_class=\"5\", envoy_http_conn_manager_prefix!~\"admin|eg-.*\"}[5m])) / sum by (cluster) (rate(envoy_http_downstream_rq_xx{envoy_http_conn_manager_prefix!~\"admin|eg-.*\"}[5m]))"
        op            = "gt"
        threshold     = 0.05
        for           = "10m"
        severity      = "warning"
        summary       = "More than 5% of Envoy Gateway requests are 5xx."
        no_data_state = "OK"
      },
    ]

    gpu = [
      {
        name      = "GPUTemperatureHigh"
        expr      = "max by (cluster) (DCGM_FI_DEV_GPU_TEMP)"
        op        = "gt"
        threshold = 85
        for       = "10m"
        severity  = "warning"
        summary   = "GPU temperature above 85C for 10 minutes."
      },
    ]

    meta = concat(
      [
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
          expr      = "sum by (cluster) (rate(prometheus_remote_storage_samples_failed_total[10m]))"
          op        = "gt"
          threshold = 0
          for       = "10m"
          severity  = "critical"
          summary   = "Alloy is failing to remote_write samples to Prometheus."
        },
        {
          name      = "ScrapeTargetDown"
          expr      = "min by (cluster, job) (up)"
          op        = "lt"
          threshold = 1
          for       = "15m"
          severity  = "warning"
          summary   = "A scrape target has been down for 15 minutes."
        },
      ],
      [
        # The count guard keeps the rule quiet while the cluster is off and sends no metrics at all
        for cluster in var.clusters : {
          name          = "CriticalScrapeTargetsAbsent-${cluster}"
          expr          = "((absent(up{job=\"kubelet\", cluster=\"${cluster}\"}) or absent(up{job=\"node-exporter\", cluster=\"${cluster}\"}) or absent(up{job=\"apiserver\", cluster=\"${cluster}\"}) or absent(up{job=\"etcd\", cluster=\"${cluster}\"}) or absent(up{job=\"kube-state-metrics\", cluster=\"${cluster}\"})) * 1) and on() (count(up{cluster=\"${cluster}\"}) > 0)"
          op            = "gt"
          threshold     = 0
          for           = "15m"
          severity      = "critical"
          summary       = "${cluster} sends metrics, but a critical scrape target (kubelet / node-exporter / apiserver / etcd / kube-state-metrics) is absent."
          no_data_state = "OK"
          labels        = { cluster = cluster }
        }
      ],
    )
  }
}
