##############################################################################
# Ansible Executor Module - Outputs
##############################################################################

output "playbook_output" {
  description = "Output from execute_playbooks. Only available after apply. Can be used to create an implicit dependency on the playbook execution."
  value       = local.use_vault ? one(terraform_data.execute_playbooks_with_vault[*].output) : one(terraform_data.execute_playbooks[*].output)
}

output "ansible_host_configured" {
  description = "Indicates whether the ansible host was configured with packages and collections."
  value       = var.configure_ansible_host
}

output "vault_encryption_enabled" {
  description = "Indicates whether vault encryption was used for the playbook."
  value       = local.use_vault
}
