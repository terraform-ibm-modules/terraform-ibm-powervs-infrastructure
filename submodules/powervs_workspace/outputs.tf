output "powervs_workspace_crn" {
  depends_on  = [ibm_resource_instance.powervs_workspace]
  description = "PowerVS infrastructure workspace CRN."
  value       = ibm_resource_instance.powervs_workspace.target_crn
}
