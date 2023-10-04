#################################################
# Attach PowerVS Subnets to CCs
#################################################

data "ibm_pi_cloud_connections" "cloud_connection_ds" {
  pi_cloud_instance_id = var.powervs_workspace_guid
}

#################################################
# Attach 2 subnets to both Cloud Connections
#################################################

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_mgmt_nw_attach" {
  count                  = var.cloud_connection_count > 0 ? 1 : 0
  pi_cloud_instance_id   = var.powervs_workspace_guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[0].cloud_connection_id
  pi_network_id          = var.powervs_subnet_ids[0]
  lifecycle {
    ignore_changes = [pi_cloud_connection_id]
  }
}

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_bkp_nw_attach" {
  depends_on             = [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach]
  count                  = var.cloud_connection_count > 0 && length(var.powervs_subnet_ids) > 1 ? 1 : 0
  pi_cloud_instance_id   = var.powervs_workspace_guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[0].cloud_connection_id
  pi_network_id          = var.powervs_subnet_ids[1]
  lifecycle {
    ignore_changes = [pi_cloud_connection_id]
  }
}

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_mgmt_nw_attach_backup" {
  depends_on             = [ibm_pi_cloud_connection_network_attach.powervs_subnet_bkp_nw_attach]
  count                  = var.cloud_connection_count > 1 ? 1 : 0
  pi_cloud_instance_id   = var.powervs_workspace_guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[1].cloud_connection_id
  pi_network_id          = var.powervs_subnet_ids[0]
  lifecycle {
    ignore_changes = [pi_cloud_connection_id]
  }
}

resource "ibm_pi_cloud_connection_network_attach" "powervs_subnet_bkp_nw_attach_backup" {
  count                  = var.cloud_connection_count > 1 && length(var.powervs_subnet_ids) > 1 ? 1 : 0
  depends_on             = [ibm_pi_cloud_connection_network_attach.powervs_subnet_mgmt_nw_attach_backup]
  pi_cloud_instance_id   = var.powervs_workspace_guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[1].cloud_connection_id
  pi_network_id          = var.powervs_subnet_ids[1]
  lifecycle {
    ignore_changes = [pi_cloud_connection_id]
  }
}
