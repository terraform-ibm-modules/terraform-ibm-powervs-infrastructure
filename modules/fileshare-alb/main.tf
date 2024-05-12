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

resource "ibm_is_lb" "file_share_alb" {

  name            = var.alb_name
  resource_group  = var.resource_group_id
  type            = "private"
  subnets         = var.alb_subnet_ids
  security_groups = var.alb_security_group_ids
}

resource "ibm_is_lb_pool" "nfs_backend_pool" {

  name                = "nfs-backend-pool"
  lb                  = ibm_is_lb.file_share_alb.id
  algorithm           = "round_robin"
  protocol            = "tcp"
  proxy_protocol      = "disabled"
  health_type         = "tcp"
  health_delay        = 5
  health_retries      = 2
  health_timeout      = 2
  health_monitor_port = 2049

}

resource "ibm_is_lb_pool_member" "nfs_backend_pool_member" {

  lb             = ibm_is_lb.file_share_alb.id
  pool           = element(split("/", ibm_is_lb_pool.nfs_backend_pool.id), 1)
  port           = 2049
  target_address = split(":", ibm_is_share_mount_target.mount_target_nfs.mount_path)[0]
}

resource "ibm_is_lb_listener" "nfs_front_end_listner" {

  lb           = ibm_is_lb.file_share_alb.id
  default_pool = ibm_is_lb_pool.nfs_backend_pool.id
  protocol     = "tcp"
  port         = 2049
}
