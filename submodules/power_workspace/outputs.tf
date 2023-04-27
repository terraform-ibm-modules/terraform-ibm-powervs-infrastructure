output "powervs_workspace_crn" {
  description = "PowerVS infrastructure workspace CRN."
  value       = ibm_resource_instance.powervs_workspace.target_crn
}
