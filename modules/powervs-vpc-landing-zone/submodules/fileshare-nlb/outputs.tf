output "file_share_nlb" {
  description = "Details of network load balancer."
  value = {
    name        = ibm_is_lb.file_share_nlb.name
    id          = ibm_is_lb.file_share_nlb.id
    private_ips = [for private_ip in ibm_is_lb.file_share_nlb.private_ip : private_ip.address]
  }
}

output "nfs_host_or_ip_path" {
  description = "NFS mount path for created infrastructure."
  value       = ibm_is_share_mount_target.mount_target_nfs.mount_path
}
