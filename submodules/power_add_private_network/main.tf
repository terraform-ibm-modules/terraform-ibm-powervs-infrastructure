#####################################################
# IBM Cloud PowerVS Resource Configuration
#####################################################

locals {
  service_type = "power-iaas"
  plan         = "power-virtual-server-group"
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
# Create Additional Private Subnet
#####################################################

resource "ibm_pi_network" "additional_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
  pi_network_name      = var.pvs_additional_network["name"]
  pi_cidr              = var.pvs_additional_network["cidr"]
  pi_dns               = ["127.0.0.1"]
  pi_network_type      = "vlan"
  pi_network_jumbo     = true
}

#####################################################
# Reuse Cloud Connection to attach PVS subnets
#####################################################

data "ibm_pi_cloud_connections" "cloud_connection_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

#########################################################################
# Extend landscape and attach additional workload specific private network
#########################################################################

resource "ibm_pi_cloud_connection_network_attach" "pvs_subnet_instance_nw_attach" {
  depends_on             = [ibm_pi_network.additional_network]
  count                  = var.new_pvs_landscape && length(data.ibm_pi_cloud_connections.cloud_connection_ds) > 0 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.pvs_service_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[0].cloud_connection_id
  pi_network_id          = ibm_pi_network.additional_network.id
}

resource "ibm_pi_cloud_connection_network_attach" "pvs_subnet_instance_nw_attach_backup" {
  depends_on             = [ibm_pi_cloud_connection_network_attach.pvs_subnet_instance_nw_attach]
  count                  = var.new_pvs_landscape && length(data.ibm_pi_cloud_connections.cloud_connection_ds) > 1 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.pvs_service_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[1].cloud_connection_id
  pi_network_id          = ibm_pi_network.additional_network.id
}

