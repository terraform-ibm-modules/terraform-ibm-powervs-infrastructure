output "file_share_alb" {
  description = "Details of application load balancer."
  value = {
    name        = ibm_is_lb.file_share_alb.name
    id          = ibm_is_lb.file_share_alb.id
    private_ips = [for private_ip in ibm_is_lb.file_share_alb.private_ip : private_ip.address]
  }
}

output "nfs_host_or_ip_path" {
  description = "NFS mount path for created infrastructure."
  value       = "${ibm_is_lb.file_share_alb.private_ip[1].address}:${split(":", ibm_is_share_mount_target.mount_target_nfs.mount_path)[1]}"
}
