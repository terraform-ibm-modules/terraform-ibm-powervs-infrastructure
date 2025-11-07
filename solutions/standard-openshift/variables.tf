variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created. Supported regions are: dal10, dal12, eu-de-1, eu-de-2, lon04, lon06, mad02, mad04, osa21, sao01, sao04, syd04, syd05, us-east, us-south, wdc06, wdc07."
  type        = string
  validation {
    condition     = contains(["dal10", "dal12", "eu-de-1", "eu-de-2", "lon04", "lon06", "mad02", "mad04", "osa21", "sao01", "sao04", "syd04", "syd05", "us-east", "us-south", "wdc06", "wdc07"], var.powervs_zone)
    error_message = "Unsupported powervs_zone. Supported zones are: dal10, dal12, eu-de-1, eu-de-2, lon04, lon06, mad02, mad04, osa21, sao01, sao04, syd04, syd05, us-east, us-south, wdc06, wdc07."
  }
}

variable "cluster_name" {
  description = "The name of the cluster and a unique identifier used as prefix for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
}

variable "tshirt_size" {
  description = "OpenShift Cluster profiles for the master and worker nodes. These profiles can be overridden by setting this value to 'custom' and specifying 'custom_master_node_config' and 'custom_woker_node_config' values in the optional parameters section."
  type        = string
  default     = "xs"

  validation {
    condition     = contains(["custom", "xs", "s", "m", "l"], var.tshirt_size)
    error_message = "Only Following values are supported: custom, xs, s, m, l"
  }
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

variable "user_id" {
  description = "The IBM Cloud login user ID associated with the account where the cluster will be deployed."
  type        = string
}

variable "openshift_pull_secret" {
  description = "Pull secret from Red Hat OpenShift Cluster Manager for authenticating OpenShift image downloads from Red Hat container registries. A RedHat account is required. It can be obtained on https://console.redhat.com/openshift/install/pull-secret."
  type        = string
  sensitive   = true
}

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
}

variable "cluster_base_domain" {
  description = "The base domain name that will be used by the cluster. Only .test, .example, and .invalid domains are supported (ie: domain.example)."
  type        = string

  validation {
    condition     = endswith(var.cluster_base_domain, ".test") || endswith(var.cluster_base_domain, ".example") || endswith(var.cluster_base_domain, ".invalid")
    error_message = "value"
  }
}

#####################################################
# Optional Parameters Openshift Cluster
#####################################################

variable "openshift_release" {
  description = "The OpenShift IPI release version to deploy."
  type        = string
  default     = "4.19.13"
}

variable "cluster_network_config" {
  description = "Configuration object for the OpenShift cluster and service network CIDRs."
  type = object({
    cluster_network_cidr         = string
    cluster_service_network_cidr = string
    cluster_machine_network_cidr = string
  })
  default = {
    "cluster_network_cidr" : "10.128.0.0/14",
    "cluster_service_network_cidr" : "10.67.0.0/16",
    "cluster_machine_network_cidr" : "10.72.0.0/24"
  }
  validation {
    condition     = can(regex("/([0-9]{1,2})$", var.cluster_network_config.cluster_network_cidr)) && tonumber(regex("/([0-9]{1,2})$", var.cluster_network_config.cluster_network_cidr)[0]) <= 14
    error_message = "The CIDR suffix must be /14 or less to ensure enough IP addresses are available in this subnet (e.g., 10.128.0.0/14)."
  }
  validation {
    condition     = can(regex("/([0-9]{1,2})$", var.cluster_network_config.cluster_service_network_cidr)) && tonumber(regex("/([0-9]{1,2})$", var.cluster_network_config.cluster_service_network_cidr)[0]) <= 16
    error_message = "The CIDR suffix must be /16 or less to ensure enough IP addresses are available in this subnet (e.g., 10.67.0.0/16)."
  }
  validation {
    condition     = can(regex("/([0-9]{1,2})$", var.cluster_network_config.cluster_network_cidr)) && tonumber(regex("/([0-9]{1,2})$", var.cluster_network_config.cluster_network_cidr)[0]) <= 24
    error_message = "The CIDR suffix must be /24 or less to ensure enough IP addresses are available in this subnet (e.g., 10.72.0.0/24)."
  }
}

variable "custom_master_node_config" {
  description = "This value is ignored if 'tshirt_size' is not set to 'custom'. Configuration for the master nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count. If system_type is null, it's chosen based on whether it's supported in the region. This can be overwritten by passing a value, e.g. 's1022' or 's922'. Memory is in GB."
  type = object({
    processors  = number
    memory      = number
    system_type = string
    proc_type   = string
    replicas    = number
  })
  default = {
    "processors" : "4",
    "memory" : "32",
    "system_type" : null,
    "proc_type" : "Shared",
    "replicas" : "3"
  }
  validation {
    condition     = var.custom_master_node_config.system_type != null ? contains(["s1122", "s1022", "s922", "e980", "e1080", "e1050"], var.custom_master_node_config.system_type) : true
    error_message = "system_type needs to be one of s1122, s1022, s922, e980, e1080, e1050."
  }
  validation {
    condition     = contains(["Capped", "Dedicated", "Shared"], var.custom_master_node_config.proc_type)
    error_message = "Unsupported value for custom_master_node_config.proc_type. Allowed values: Capped, Dedicated, Shared."
  }
  validation {
    condition     = var.custom_master_node_config.memory >= 2 && var.custom_master_node_config.memory <= 64
    error_message = "Memory needs to be at least 2 and at most 64."
  }
  validation {
    condition     = var.custom_master_node_config.replicas == 1 || var.custom_master_node_config.replicas == 3
    error_message = "The number of master nodes needs to be 3 or 1 for single-node openshift."
  }
}

variable "custom_worker_node_config" {
  description = "This value is ignored if 'tshirt_size' is not set to 'custom'. Configuration for the worker nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count. If system_type is null, it's chosen based on whether it's supported in the region. This can be overwritten by passing a value, e.g. 's1022' or 's922'. Memory is in GB."
  type = object({
    processors  = number
    memory      = number
    system_type = string
    proc_type   = string
    replicas    = number
  })
  default = {
    "processors" : "4",
    "memory" : "32",
    "system_type" : null,
    "proc_type" : "Shared",
    "replicas" : "3"
  }
  validation {
    condition     = var.custom_worker_node_config.system_type != null ? contains(["s1122", "s1022", "s922", "e980", "e1080", "e1050"], var.custom_worker_node_config.system_type) : true
    error_message = "system_type needs to be one of s1122, s1022, s922, e980, e1080, e1050."
  }
  validation {
    condition     = contains(["Capped", "Dedicated", "Shared"], var.custom_worker_node_config.proc_type)
    error_message = "Unsupported value for custom_worker_node_config.proc_type. Allowed values: Capped, Dedicated, Shared."
  }
  validation {
    condition     = var.custom_worker_node_config.memory >= 2 && var.custom_worker_node_config.memory <= 64
    error_message = "Memory needs to be at least 2 and at most 64."
  }
  validation {
    condition     = var.custom_worker_node_config.replicas >= 2
    error_message = "The number of worker nodes needs to be 2 or more."
  }
}

#####################################################
# Optional Parameters PowerVS Workspace
#####################################################

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS workspace"
  type        = list(string)
  default     = []
}

#####################################################
# Optional Parameters for intel VSI
#####################################################

variable "vpc_intel_images" {
  description = "Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring)."
  type = object({
    rhel_image = string
    sles_image = string
  })
  default = {
    "rhel_image" : "ibm-redhat-9-4-amd64-sap-applications-7",
    "sles_image" : "ibm-sles-15-7-amd64-sap-applications-1"
  }
}

variable "network_services_vsi_profile" {
  description = "Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  type        = string
  default     = "cx2-2x4"
}

variable "intel_user_data" {
  description = "User data that automatically performs common configuration tasks or runs scripts only on the intel VSIs. For more information, see https://cloud.ibm.com/docs/vpc?topic=vpc-user-data. For information on using the user_data variable, please refer: https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-user-data"
  type        = string
  default     = null
}

variable "external_access_ip" {
  description = "Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn."
  type        = string
  default     = "0.0.0.0/0"
}

#####################################################
# Optional Parameters Monitoring and SCC WP Instance
#####################################################

variable "enable_scc_wp" {
  description = "Enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all intel VSIs in this deployment."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Specify whether Monitoring will be enabled. This creates a new IBM Cloud Monitoring Instance."
  type        = bool
  default     = false
}

###########################################################
# Optional Parameters Secret Manager for client to site VPN
###########################################################

variable "client_to_site_vpn" {
  description = "VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance."
  type = object({
    enable                        = bool
    client_ip_pool                = string
    vpn_client_access_group_users = list(string)
  })

  default = {
    "enable" : true,
    "client_ip_pool" : "192.168.0.0/16",
    "vpn_client_access_group_users" : []
  }
}

variable "sm_service_plan" {
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null."
  type        = string
  default     = "standard"
}

variable "existing_sm_instance_guid" {
  description = "An existing Secrets Manager GUID. If not provided a new instance will be provisioned."
  type        = string
  default     = null
}

variable "existing_sm_instance_region" {
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  type        = string
  default     = null
}

#############################################################################
# Schematics Output
#############################################################################

# tflint-ignore: all
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace"
  type        = string
  default     = ""
}
