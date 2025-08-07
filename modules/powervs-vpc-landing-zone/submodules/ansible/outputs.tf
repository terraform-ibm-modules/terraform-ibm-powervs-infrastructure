output "playbook_output" {
  description = "Output from execute_playbooks. Only available after apply. Can be used to create an implicit dependency on the playbook execution."
  value       = var.ansible_vault_password == null ? terraform_data.execute_playbooks[0].output : terraform_data.execute_playbooks_with_vault[0].output
}
