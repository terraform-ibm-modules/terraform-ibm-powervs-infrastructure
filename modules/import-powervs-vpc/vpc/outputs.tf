output "vsi_details" {
  description = "VSI Information."
  value       = local.vsi_details
}

output "vsi_ds" {
  description = "VSI as is"
  value       = data.ibm_is_instance.vsi_ds
}

output "vsi_ssh_public_key" {
  description = "VSI SSH Public key"
  value       = data.ibm_is_ssh_key.jump_host_ssh_key_ds
}

output "vpc" {
  description = "VPC's data"
  value       = data.ibm_is_vpc.vpc_ds
}
