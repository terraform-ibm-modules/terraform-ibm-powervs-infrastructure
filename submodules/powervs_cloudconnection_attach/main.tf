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


#####################################################
# Get IBM Cloud PowerVS subnet IDs
#####################################################

data "ibm_pi_network" "powervs_subnets_ds" {
  count                = length(var.powervs_subnet_names)
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_network_name      = var.powervs_subnet_names[count.index]
}

#####################################################
# Reuse Cloud Connection to attach PVS subnets
#####################################################

data "ibm_pi_cloud_connections" "cloud_connection_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_workspace_ds.guid
}

#########################################################################
# Initialize landscape and attach management and backup private networks
#########################################################################

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_mgmt_nw_attach" {
  depends_on             = [data.ibm_pi_network.powervs_subnets_ds[0]]
  count                  = var.cloud_connection_count > 0 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[0].cloud_connection_id
  pi_network_id          = data.ibm_pi_network.powervs_subnets_ds[0].id
}

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_bkp_nw_attach" {
  depends_on             = [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach, data.ibm_pi_network.powervs_subnets_ds[1]]
  count                  = var.cloud_connection_count > 0 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[0].cloud_connection_id
  pi_network_id          = data.ibm_pi_network.powervs_subnets_ds[1].id
}

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_mgmt_nw_attach_backup" {
  depends_on             = [ibm_pi_cloud_connection_network_attach.powervs_subnet_bkp_nw_attach]
  count                  = var.cloud_connection_count > 1 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[1].cloud_connection_id
  pi_network_id          = data.ibm_pi_network.powervs_subnets_ds[0].id
}

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_bkp_nw_attach_backup" {
  count                  = var.cloud_connection_count > 1 ? 1 : 0
  depends_on             = [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach_backup]
  pi_cloud_instance_id   = data.ibm_resource_instance.powervs_workspace_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[1].cloud_connection_id
  pi_network_id          = data.ibm_pi_network.powervs_subnets_ds[1].id
}
