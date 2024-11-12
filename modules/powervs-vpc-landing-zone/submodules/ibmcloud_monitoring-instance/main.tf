locals {
  name_ibm_cloud_monitoring_instance = "IBM Cloud Monitoring-instance-terraformed"
  location                           = "br-sao"
}

resource "ibm_resource_instance" "create-instance-monitor" {
  name     = local.name_ibm_cloud_monitoring_instance
  location = local.location
  service  = "sysdig-monitor"
  plan     = "graduated-tier"
  tags = [
    "monitoring",
  ]
}
