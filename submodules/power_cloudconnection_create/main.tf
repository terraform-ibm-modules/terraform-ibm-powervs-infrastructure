#####################################################
# IBM Cloud PowerVS cloud connection Configuration
#####################################################

locals {
  service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.powervs_resource_group_name
}

data "ibm_resource_instance" "powervs_workspace_ds" {
  name              = var.powervs_workspace_name
  service           = local.service_type
  location          = var.powervs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}

locals {
  cloud_connection_name_1 = var.cloud_connection_name_prefix != null && var.cloud_connection_name_prefix != "" ? "${var.cloud_connection_name_prefix}-${var.powervs_zone}-conn-1" : "${var.powervs_zone}-conn-1"
  cloud_connection_name_2 = var.cloud_connection_name_prefix != null && var.cloud_connection_name_prefix != "" ? "${var.cloud_connection_name_prefix}-${var.powervs_zone}-conn-2" : "${var.powervs_zone}-conn-2"
}

#####################################################
# Create Cloud Connection to attach PVS subnets
#####################################################

resource "ibm_pi_cloud_connection" "cloud_connection" {
  count                               = var.cloud_connection_count > 0 ? 1 : 0
  pi_cloud_instance_id                = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_cloud_connection_name            = local.cloud_connection_name_1
  pi_cloud_connection_speed           = var.cloud_connection_speed
  pi_cloud_connection_global_routing  = var.cloud_connection_gr
  pi_cloud_connection_metered         = var.cloud_connection_metered
  pi_cloud_connection_transit_enabled = true
}

resource "ibm_pi_cloud_connection" "cloud_connection_backup" {
  depends_on                          = [ibm_pi_cloud_connection.cloud_connection]
  count                               = var.cloud_connection_count > 1 ? 1 : 0
  pi_cloud_instance_id                = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_cloud_connection_name            = local.cloud_connection_name_2
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
  count      = var.cloud_connection_count > 0 ? 1 : 0
  name       = local.cloud_connection_name_1
}

data "ibm_dl_gateway" "gateway_ds_2" {
  count      = var.cloud_connection_count > 1 ? 1 : 0
  depends_on = [ibm_pi_cloud_connection.cloud_connection_backup]
  name       = local.cloud_connection_name_2
}

resource "time_sleep" "dl_1_resource_propagation" {
  depends_on      = [data.ibm_dl_gateway.gateway_ds_1]
  count           = var.cloud_connection_count > 0 ? 1 : 0
  create_duration = "120s"
  triggers = {
    dl_crn = data.ibm_dl_gateway.gateway_ds_1[0].crn
  }
}

resource "time_sleep" "dl_2_resource_propagation" {
  depends_on      = [data.ibm_dl_gateway.gateway_ds_2]
  count           = var.cloud_connection_count > 1 ? 1 : 0
  create_duration = "120s"
  triggers = {
    dl_crn = data.ibm_dl_gateway.gateway_ds_2[0].crn
  }
}

#####################################################
# Attach direct link CRNs to transit gateway
#####################################################

resource "ibm_tg_connection" "ibm_tg_connection_1" {
  depends_on   = [ibm_pi_cloud_connection.cloud_connection_backup]
  count        = var.cloud_connection_count > 0 ? 1 : 0
  gateway      = data.ibm_tg_gateway.tg_gateway_ds.id
  network_type = "directlink"
  name         = local.cloud_connection_name_1
  network_id   = time_sleep.dl_1_resource_propagation[0].triggers["dl_crn"]
}

resource "ibm_tg_connection" "ibm_tg_connection_2" {
  depends_on   = [ibm_tg_connection.ibm_tg_connection_1]
  count        = var.cloud_connection_count > 1 ? 1 : 0
  gateway      = data.ibm_tg_gateway.tg_gateway_ds.id
  network_type = "directlink"
  name         = local.cloud_connection_name_2
  network_id   = time_sleep.dl_2_resource_propagation[0].triggers["dl_crn"]
}
