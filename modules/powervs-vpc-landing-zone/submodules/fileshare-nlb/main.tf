#####################################################
# File share for NFS and application Load Balancer
#####################################################

resource "ibm_is_share" "file_share_nfs" {

  name                = var.file_share_name
  size                = var.file_share_size
  profile             = "dp2"
  access_control_mode = "security_group"
  iops                = var.file_share_iops
  zone                = var.vpc_zone
  resource_group      = var.resource_group_id
}

resource "ibm_is_share_mount_target" "mount_target_nfs" {

  name  = var.file_share_mount_target_name
  share = ibm_is_share.file_share_nfs.id
  virtual_network_interface {
    name            = var.file_share_mount_target_name
    resource_group  = var.resource_group_id
    subnet          = var.file_share_subnet_id
    security_groups = var.file_share_security_group_ids
  }
}

resource "ibm_is_lb" "file_share_nlb" {

  name            = var.nlb_name
  resource_group  = var.resource_group_id
  type            = "private"
  subnets         = var.nlb_subnet_ids
  profile         = "network-fixed"
  security_groups = var.nlb_security_group_ids
  route_mode      = true
}

resource "ibm_is_lb_pool" "nfs_backend_pool" {

  name                = "nfs-backend-pool"
  lb                  = ibm_is_lb.file_share_nlb.id
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

  lb           = ibm_is_lb.file_share_nlb.id
  default_pool = ibm_is_lb_pool.nfs_backend_pool.id
  protocol     = "tcp"
  port         = 2049
}

resource "ibm_is_vpc_routing_table" "nfs_routing_table" {

  name                          = var.routing_table_name
  vpc                           = ibm_is_share_mount_target.mount_target_nfs.vpc
  route_direct_link_ingress     = false
  route_transit_gateway_ingress = true
  route_vpc_zone_ingress        = false

}

resource "ibm_is_vpc_routing_table_route" "nfs_route" {

  name          = "nfs-route"
  vpc           = ibm_is_share_mount_target.mount_target_nfs.vpc
  routing_table = ibm_is_vpc_routing_table.nfs_routing_table.routing_table
  zone          = var.vpc_zone
  destination   = "${split(":", ibm_is_share_mount_target.mount_target_nfs.mount_path)[0]}/32"
  action        = "deliver"
  advertise     = false
  next_hop      = ibm_is_lb.file_share_nlb.private_ips[0]
}
