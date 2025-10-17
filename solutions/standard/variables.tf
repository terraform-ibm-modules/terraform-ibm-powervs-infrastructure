variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "external_access_ip" {
  description = "Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. If you're unsure how to create one, check [Generate a SSH Key Pair](https://cloud.ibm.com/docs/powervs-vpc?topic=powervs-vpc-powervs-automation-prereqs#powervs-automation-ssh-key) in our docs. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the VPC docs."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh_public_key'. The key is not uploaded or stored. If you're unsure how to create one, check [Generate a SSH Key Pair](https://cloud.ibm.com/docs/powervs-vpc?topic=powervs-vpc-powervs-automation-prereqs#powervs-automation-ssh-key) in our docs. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the VPC docs."
  type        = string
  sensitive   = true
}

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

#####################################################
# Optional Parameters VPC
#####################################################

variable "vpc_subnet_cidrs" {
  description = "CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool."
  type = object({
    vpn  = string
    mgmt = string
    vpe  = string
    edge = string
  })
  default = {
    "vpn"  = "10.30.10.0/24"
    "mgmt" = "10.30.20.0/24"
    "vpe"  = "10.30.30.0/24"
    "edge" = "10.30.40.0/24"
  }
}

#####################################################
# Optional Parameters PowerVS Workspace
#####################################################

variable "powervs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create."
  type = object({
    name = string
    cidr = string
  })

  default = {
    "name" : "mgmt_net",
    "cidr" : "10.51.0.0/24"
  }

  validation {
    condition     = var.powervs_management_network != null ? can(regex("^([a-z]|[a-z][-_a-z0-9]*[a-z0-9])$", var.powervs_management_network.name)) : true
    error_message = "powervs_management_network.name can only contain 'a-z', '0-9', '-', '_' and must end on a letter or number."
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
    "cidr" : "10.52.0.0/24"
  }

  validation {
    condition     = var.powervs_backup_network != null ? can(regex("^([a-z]|[a-z][-_a-z0-9]*[a-z0-9])$", var.powervs_backup_network.name)) : true
    error_message = "powervs_backup_network.name can only contain 'a-z', '0-9', '-', '_' and must end on a letter or number."
  }
}

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS workspace."
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
  description = "Cloud Object Storage bucket containing custom PowerVS images. bucket_name: string, name of the COS bucket. bucket_access: string, possible values: public, private (private requires powervs_custom_image_cos_service_credentials). bucket_region: string, COS bucket region."
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

#####################################################
# Optional Parameter Transit gateway
#####################################################

variable "transit_gateway_global" {
  description = "Connect to the networks outside the associated region."
  type        = bool
  default     = false
}

#####################################################
# Optional Parameter Network Services VSI Profile
#####################################################

variable "vpc_intel_images" {
  description = "Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring)."
  type = object({
    rhel_image = string
    sles_image = string
  })
  default = {
    "rhel_image" : "ibm-redhat-9-6-amd64-sap-applications-1"
    "sles_image" : "ibm-sles-15-7-amd64-sap-applications-1"
  }
}

variable "network_services_vsi_profile" {
  description = "Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  type        = string
  default     = "cx2-2x4"
}

#####################################################
# Optional Parameters VSI OS Management Services
#####################################################

variable "configure_dns_forwarder" {
  description = "Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns_forwarder_config' optional variable is set properly. DNS forwarder will be installed on the network-services vsi."
  type        = bool
  default     = true
}

variable "configure_ntp_forwarder" {
  description = "Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the network-services vsi."
  type        = bool
  default     = true
}

variable "configure_nfs_server" {
  description = "Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). [File storage share and mount target](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui) in VPC will be created.. If yes, ensure 'nfs_server_config' optional variable is set properly below. Default value is '200GB' which will be mounted on specified directory in network-service vsi."
  type        = bool
  default     = true
}

variable "dns_forwarder_config" {
  description = "Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS."
  type = object({
    dns_servers = string
  })

  default = {
    "dns_servers" : "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "nfs_server_config" {
  description = "Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount_path' defines the target mount point on os. Set 'configure_nfs_server' to false to ignore creating file storage share."
  type = object({
    size       = number
    iops       = number
    mount_path = string
  })

  default = {
    "size" : 200,
    "iops" : 600,
    "mount_path" : "/nfs"
  }
}

#################################################
# Optional Parameters SCC Workload Protection
#################################################

variable "enable_scc_wp" {
  description = "Enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all intel VSIs in this deployment. If set to true, then value for 'ansible_vault_password' in optional parameter must be set."
  type        = bool
  default     = false
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  default     = null
}

#################################################
# Optional Parameters Monitoring Instance
#################################################

variable "enable_monitoring" {
  description = "Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance. If you already have an existing monitoring instance, set this to true and specify in optional parameter 'existing_monitoring_instance_crn'."
  type        = bool
  default     = false
}

variable "enable_monitoring_host" {
  description = "Specify whether to create an additional Intel Instance that can be used to configure additional monitoring services."
  type        = bool
  default     = false
}

variable "existing_monitoring_instance_crn" {
  description = "Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable_monitoring_host' is true. "
  type        = string
  default     = null
}



#####################################################
# Optional Parameters Secret Manager
#####################################################

variable "client_to_site_vpn" {
  description = "VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance."
  type = object({
    enable                        = bool
    client_ip_pool                = string
    vpn_client_access_group_users = list(string)
  })

  default = {
    "enable" : false,
    "client_ip_pool" : "192.168.0.0/16",
    "vpn_client_access_group_users" : []
  }
}

variable "sm_service_plan" {
  type        = string
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null."
  default     = "standard"
}

variable "existing_sm_instance_guid" {
  type        = string
  description = "An existing Secrets Manager GUID. If not provided a new instance will be provisioned."
  default     = null
}

variable "existing_sm_instance_region" {
  type        = string
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  default     = null
}

#############################################################################
# Schematics Output
#############################################################################

# tflint-ignore: all
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace."
  type        = string
  default     = ""
}
