#####################################################
# IBM Cloud PowerVS cloud connection Configuration
#####################################################

locals {
  service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.pvs_resource_group_name
}

data "ibm_resource_instance" "pvs_service_ds" {
  name              = var.pvs_service_name
  service           = local.service_type
  location          = var.pvs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}


#####################################################
# Create Cloud Connection to attach PVS subnets
#####################################################

resource "ibm_pi_cloud_connection" "cloud_connection" {
  pi_cloud_instance_id                = data.ibm_resource_instance.pvs_service_ds.guid
  pi_cloud_connection_name            = "${var.pvs_zone}-conn-1"
  pi_cloud_connection_speed           = var.cloud_connection_speed
  pi_cloud_connection_global_routing  = var.cloud_connection_gr
  pi_cloud_connection_metered         = var.cloud_connection_metered
  pi_cloud_connection_transit_enabled = true
}

resource "ibm_pi_cloud_connection" "cloud_connection_backup" {
  depends_on                          = [ibm_pi_cloud_connection.cloud_connection]
  count                               = var.cloud_connection_count > 1 ? 1 : 0
  pi_cloud_instance_id                = data.ibm_resource_instance.pvs_service_ds.guid
  pi_cloud_connection_name            = "${var.pvs_zone}-conn-2"
  pi_cloud_connection_speed           = var.cloud_connection_speed
  pi_cloud_connection_global_routing  = var.cloud_connection_gr
  pi_cloud_connection_metered         = var.cloud_connection_metered
  pi_cloud_connection_transit_enabled = true
}

#####################################################
# Get transit gateway
#####################################################

data "ibm_tg_gateway" "tg_gateway_ds" {
  name = var.transit_gateway_name
}

#####################################################
# Get direct link CRNs from created cloud connections
#####################################################

data "ibm_dl_gateway" "gateway_ds_1" {
  depends_on = [ibm_pi_cloud_connection.cloud_connection]
  name       = "${var.pvs_zone}-conn-1"
}

data "ibm_dl_gateway" "gateway_ds_2" {
  count      = var.cloud_connection_count > 1 ? 1 : 0
  depends_on = [ibm_pi_cloud_connection.cloud_connection_backup]
  name       = "${var.pvs_zone}-conn-2"
}


#####################################################
# Attach direct link CRNs to transit gateway
#####################################################

resource "ibm_tg_connection" "ibm_tg_connection_1" {
  depends_on   = [ibm_pi_cloud_connection.cloud_connection_backup]
  gateway      = data.ibm_tg_gateway.tg_gateway_ds.id
  network_type = "directlink"
  name         = "${var.pvs_zone}-conn-1"
  network_id   = data.ibm_dl_gateway.gateway_ds_1.crn
}

resource "ibm_tg_connection" "ibm_tg_connection_2" {
  depends_on   = [ibm_tg_connection.ibm_tg_connection_1]
  count        = var.cloud_connection_count > 1 ? 1 : 0
  gateway      = data.ibm_tg_gateway.tg_gateway_ds.id
  network_type = "directlink"
  name         = "${var.pvs_zone}-conn-2"
  network_id   = data.ibm_dl_gateway.gateway_ds_2[0].crn
  #time_sleep.dl_resource_propagation.triggers["dl_2_crn"]
}
