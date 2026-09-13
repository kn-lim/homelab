variable "datasource_uid" {
  description = "UID of the Prometheus data source that alert rule queries run against."
  type        = string
}

variable "clusters" {
  description = "Cluster names that ship metrics to this Prometheus. One absent-target rule renders per cluster."
  type        = list(string)
}
