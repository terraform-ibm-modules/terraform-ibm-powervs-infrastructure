locals {
  name_ibm_cloud_monitoring_instance = "IBM Cloud Monitoring-instance-terraformed"
  region               = var.region

}

resource "ibm_resource_instance" "create-instance-monitor" {
  name     = local.name_ibm_cloud_monitoring_instance
  location = local.region
  service  = "sysdig-monitor"
  plan     = "graduated-tier"
  tags = [
    "monitoring",
  ]
}

