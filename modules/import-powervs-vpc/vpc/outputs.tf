output "vsi_details" {
  description = "VSI Information."
  value       = local.vsi_details
}

output "vsi_ds" {
  description = "The retrieved VSI data."
  value       = data.ibm_is_instance.vsi_ds
}

output "vsi_ssh_public_key" {
  description = "VSI SSH Public key."
  value       = data.ibm_is_ssh_key.jump_host_ssh_key_ds
}

output "vpc" {
  description = "The retrieved VPC data."
  value       = data.ibm_is_vpc.vpc_ds
}
