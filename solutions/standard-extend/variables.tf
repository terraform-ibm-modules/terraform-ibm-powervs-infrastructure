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
  description = "List of Images to be imported into cloud account from catalog images. Supported values can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md). For custom os image import configure the optional parameter 'powervs_custom_images'."
  type        = list(string)
  default     = ["IBMi-75-04-2984-1", "IBMi-74-10-2984-1", "7200-05-08", "7300-02-01", "SLES15-SP5-SAP", "SLES15-SP5-SAP-NETWEAVER", "RHEL9-SP4-SAP", "RHEL9-SP4-SAP-NETWEAVER"]
}

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS workspace"
  type        = list(string)
  default     = []
}

variable "powervs_custom_images" {
  description = "Optionally import up to three custom images from Cloud Object Storage into PowerVS workspace. Requires 'powervs_custom_image_cos_configuration' to be set. image_name: string, must be unique. Name of image inside PowerVS workspace. file_name: string, object key of image inside COS bucket. storage_tier: string, storage tier which image will be stored in after import. Supported values: tier0, tier1, tier3, tier5k. sap_type: optional string, Supported values: null, Hana, Netweaver, use null for non-SAP image."
  type = object({
    powervs_custom_image1 = object({
      image_name   = string
      file_name    = string
      storage_tier = string
      sap_type     = optional(string)
    }),
    powervs_custom_image2 = object({
      image_name   = string
      file_name    = string
      storage_tier = string
      sap_type     = optional(string)
    }),
    powervs_custom_image3 = object({
      image_name   = string
      file_name    = string
      storage_tier = string
      sap_type     = optional(string)
    })
  })
  default = {
    "powervs_custom_image1" : {
      "image_name" : "",
      "file_name" : "",
      "storage_tier" : "",
      "sap_type" : null
    },
    "powervs_custom_image2" : {
      "image_name" : "",
      "file_name" : "",
      "storage_tier" : "",
      "sap_type" : null
    },
    "powervs_custom_image3" : {
      "image_name" : "",
      "file_name" : "",
      "storage_tier" : "",
      "sap_type" : null
    }
  }
}

variable "powervs_custom_image_cos_configuration" {
  description = "Cloud Object Storage bucket containing custom PowerVS images. bucket_name: string, name of the COS bucket. bucket_access: string, possible values: public, private (private requires powervs_custom_image_cos_service_credentials). bucket_region: string, COS bucket region"
  type = object({
    bucket_name   = string
    bucket_access = string
    bucket_region = string
  })
  default = {
    "bucket_name" : "",
    "bucket_access" : "",
    "bucket_region" : ""
  }
}

variable "powervs_custom_image_cos_service_credentials" {
  description = "Service credentials for the Cloud Object Storage bucket containing the custom PowerVS images. The bucket must have HMAC credentials enabled. Click [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) for a json example of a service credential."
  type        = string
  sensitive   = true
  default     = null
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
