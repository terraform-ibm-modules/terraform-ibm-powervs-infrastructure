output "vsi_info" {
  description = "VSI Information."
  value       = local.vsi_info
}

output "vsi_as_is" {
  description = "VSI as is"
  value       = data.ibm_is_instance.vsi
}

output "vsi_ssh_public_key" {
  description = "VSI SSH Public key"
  value       = data.ibm_is_ssh_key.jump_host_ssh_key
}

output "vpc" {
  description = "VPC's data"
  value       = data.ibm_is_vpc.vpc
}
