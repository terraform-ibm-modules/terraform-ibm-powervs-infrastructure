#####################################################
# File share for NFS and Network Load Balancer
#####################################################

locals {
  vpc_zone                      = "${lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)}-${local.availability_zone_number}"
  resource_group_id             = module.landing_zone.resource_group_data["${var.prefix}-${local.second_rg_name}"]
  file_share_name               = "${var.prefix}-file-share-nfs"
  file_share_size               = var.nfs_server_config.size
  file_share_iops               = var.nfs_server_config.iops
  file_share_mount_target_name  = "${var.prefix}-nfs"
  file_share_subnet_id          = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-${local.availability_zone}"][0]
  file_share_security_group_ids = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]
  nlb_name                      = "${var.prefix}-file-share-nlb"
  nlb_subnet_ids                = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-${local.availability_zone}"]
  nlb_security_group_ids        = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]
}

resource "ibm_is_share" "file_share_nfs" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name                = local.file_share_name
  size                = local.file_share_size
  profile             = "dp2"
  access_control_mode = "security_group"
  iops                = local.file_share_iops
  zone                = local.vpc_zone
  resource_group      = local.resource_group_id
}

resource "ibm_is_share_mount_target" "mount_target_nfs" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name  = local.file_share_mount_target_name
  share = ibm_is_share.file_share_nfs[0].id
  virtual_network_interface {
    name            = local.file_share_mount_target_name
    resource_group  = local.resource_group_id
    subnet          = local.file_share_subnet_id
    security_groups = local.file_share_security_group_ids
  }
}

resource "ibm_is_lb" "file_share_nlb" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name            = local.nlb_name
  resource_group  = local.resource_group_id
  type            = "private"
  subnets         = local.nlb_subnet_ids
  profile         = "network-fixed"
  security_groups = local.nlb_security_group_ids
  route_mode      = true
}

resource "ibm_is_lb_pool" "nfs_backend_pool" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name                = "nfs-backend-pool"
  lb                  = ibm_is_lb.file_share_nlb[0].id
  algorithm           = "round_robin"
  protocol            = "tcp"
  health_type         = "tcp"
  health_delay        = 5
  health_retries      = 2
  health_timeout      = 2
  health_monitor_port = 2049
  failsafe_policy {
    action = "bypass"
  }
}

resource "ibm_is_lb_listener" "nfs_front_end_listener" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  lb           = ibm_is_lb.file_share_nlb[0].id
  default_pool = ibm_is_lb_pool.nfs_backend_pool[0].id
  protocol     = "tcp"
}

resource "ibm_is_vpc_routing_table_route" "nfs_route" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name          = "nfs-route"
  vpc           = ibm_is_share_mount_target.mount_target_nfs[0].vpc
  routing_table = ibm_is_vpc_routing_table.routing_table[0].routing_table
  zone          = local.vpc_zone
  destination   = "${split(":", ibm_is_share_mount_target.mount_target_nfs[0].mount_path)[0]}/32"
  action        = "deliver"
  advertise     = false
  next_hop      = ibm_is_lb.file_share_nlb[0].private_ips[0]
}

locals {
  nfs_host_or_ip_path = var.configure_nfs_server ? ibm_is_share_mount_target.mount_target_nfs[0].mount_path : ""
  file_share_nlb = var.configure_nfs_server ? {
    name        = ibm_is_lb.file_share_nlb[0].name
    id          = ibm_is_lb.file_share_nlb[0].id
    private_ips = [for private_ip in ibm_is_lb.file_share_nlb[0].private_ip : private_ip.address]
    } : {
    name        = ""
    id          = ""
    private_ips = []
  }
}
