variable "prerequisite_workspace_id" {
  description = "IBM Cloud Schematics workspace ID of the prerequisite infrastructure. If you do not have an existing deployment yet, create a new architecture using the same catalog tile."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create."
  type = object({
    name = string
    cidr = string
  })

  default = {
    "name" : "mgmt_net",
    "cidr" : "10.61.0.0/24"
  }
}

variable "powervs_backup_network" {
  description = "Name of the IBM Cloud PowerVS backup network and CIDR to create."
  type = object({
    name = string
    cidr = string
  })

  default = {
    "name" : "bkp_net",
    "cidr" : "10.62.0.0/24"
  }
}

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

#####################################################
# Optional Parameters
#####################################################

variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images. Supported values can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md)"
  type        = list(string)
  default     = ["IBMi-75-03-2924-2", "IBMi-74-09-2984-1", "7200-05-07", "7300-02-01", "SLES15-SP5-SAP", "SLES15-SP5-SAP-NETWEAVER", "RHEL9-SP2-SAP", "RHEL9-SP2-SAP-NETWEAVER"]
}

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS workspace"
  type        = list(string)
  default     = []
}

#############################################################################
# Schematics Output
#############################################################################

# tflint-ignore: terraform_naming_convention
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  default     = ""
  type        = string
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace"
}
