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

variable "custom_pi_images" {
  description = <<EOF
    Optional list of custom images to import from Cloud Object Storage into PowerVS workspace.
      image_name: string, must be unique image name how the image will be named inside PowerVS workspace
      file_name: string, full file name of the image inside COS bucket
      storage_tier: string, storage tier which the image will be stored in after import. Must be one of the storage tiers supported in the PowerVS workspace region. Available tiers can be found using `ibmcloud pi storage-tiers`. Typical values are: "tier0", "tier1", "tier3", "tier5k"
      sap_type: string, "Hana", "Netweaver". Set to null if it's not an SAP image.
  EOF
  type = list(object({
    image_name   = string
    file_name    = string
    storage_tier = string
    sap_type     = string
  }))
  validation {
    condition     = length([for image in var.custom_pi_images : image.image_name]) == length(distinct([for image in var.custom_pi_images : image.image_name]))
    error_message = "Duplicate image_name detected. All image names must be unique in their workspace."
  }
  validation {
    condition     = alltrue([for image in var.custom_pi_images : image.sap_type == null ? true : contains(["Hana", "Netweaver"], image.sap_type)])
    error_message = "Unsupported sap_type. Supported values: null, \"Hana\", \"Netweaver\"."
  }
  default = []
}

variable "custom_pi_image_cos_configuration" {
  description = <<EOF
    Cloud Object Storage bucket containing the custom PowerVS images. Images will be imported into the PowerVS Workspace.
      bucket_name: string, name of the COS bucket
      bucket_access: string, possible values: "public", "private" (private requires custom_pi_image_cos_service_credentials)
      bucket_region: string, COS bucket region
  EOF
  type = object({
    bucket_name   = string
    bucket_access = string
    bucket_region = string
  })
  default = null
  validation {
    condition     = var.custom_pi_image_cos_configuration != null ? contains(["public", "private"], var.custom_pi_image_cos_configuration.bucket_access) : true
    error_message = "Invalid custom_pi_image_cos_configuration.bucket_access. Allowed values: [\"public\", \"private\"]."
  }
  validation {
    condition     = length(var.custom_pi_images) > 0 ? var.custom_pi_image_cos_configuration != null : true
    error_message = "The import of custom images into PowerVS workspace requires a cos configuration. custom_pi_image_cos_configuration undefined."
  }
}

variable "custom_pi_image_cos_service_credentials" {
  description = "Service credentials for the Cloud Object Storage bucket containing the custom PowerVS images. The bucket must have HMAC credentials enabled. Click [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) for a json example of a service credential."
  type        = string
  sensitive   = true
  default     = null
  validation {
    condition     = var.custom_pi_image_cos_configuration != null ? var.custom_pi_image_cos_configuration.bucket_access == "private" ? var.custom_pi_image_cos_service_credentials != null : true : true
    error_message = "custom_pi_image_cos_service_credentials are required to access private COS buckets."
  }
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
