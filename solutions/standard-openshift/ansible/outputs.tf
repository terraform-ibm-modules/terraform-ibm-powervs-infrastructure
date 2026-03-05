##############################################################################
# OpenShift Ansible Module - Outputs
##############################################################################

output "playbook_output" {
  description = "Output from execute_playbooks. Only available after apply. Can be used to create an implicit dependency on the playbook execution."
  value       = module.ansible_executor.playbook_output
}

output "ansible_host_configured" {
  description = "Indicates whether the ansible host was configured with packages and collections."
  value       = module.ansible_executor.ansible_host_configured
}

output "vault_encryption_enabled" {
  description = "Indicates whether vault encryption was used for the playbook."
  value       = module.ansible_executor.vault_encryption_enabled
}
