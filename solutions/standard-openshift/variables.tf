variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh_public_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "user_id" {
  description = "The IBM Cloud login user ID associated with the account where the cluster will be deployed."
  type        = string
}

variable "openshift_pull_secret" {
  description = "Pull secret from Red Hat OpenShift Cluster Manager for authenticating OpenShift image downloads from Red Hat container registries."
  type        = map(any)
  sensitive   = true
}

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

# required?
variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
}

variable "cluster_base_domain" {
  description = "The base domain name that will be used by the cluster. (ie: example.com)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster."
  type        = string
}

#####################################################
# Optional Parameters PowerVS Instance
#####################################################

variable "custom_profile_instance_boot_image" {
  description = "Override the t-shirt size specs of PowerVS Workspace instance by selecting an image name and providing valid 'custom_profile' optional parameter."
  type        = string
  default     = "none"
}

#####################################################
# Optional Parameters Openshift Cluster
#####################################################

variable "openshift_release" {
  description = "The OpenShift IPI release version to deploy."
  type        = string
  default     = "4.19.5"
}

variable "cluster_dir" {
  description = "The directory that holds the artifacts of the OpenShift cluster creation."
  type        = string
  default     = "ocp-powervs-deploy"
}

variable "cluster_network_config" {
  description = "Configuration object for the OpenShift cluster and service network CIDRs."
  type = object({
    cluster_network_cidr         = string
    cluster_service_network_cidr = string
  })
  default = {
    cluster_network_cidr         = "172.168.0.0/22"
    cluster_service_network_cidr = "10.67.0.0/24"
  }
}

variable "cluster_master_node_config" {
  description = "Configuration for the master nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count."
  type = object({
    processors  = number
    system_type = string
    proc_type   = string
    replicas    = number
  })
  default = {
    processors  = 4
    system_type = "s1022"
    proc_type   = "Dedicated"
    replicas    = 3
  }
}

variable "cluster_worker_node_config" {
  description = "Configuration for the worker nodes of the OpenShift cluster, including CPU, system type, processor type, and replica count."
  type = object({
    processors  = number
    system_type = string
    proc_type   = string
    replicas    = number
  })
  default = {
    processors  = 4
    system_type = "s1022"
    proc_type   = "Dedicated"
    replicas    = 3
  }
}

#####################################################
# Optional Parameters PowerVS Workspace
#####################################################

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
  default     = "Default"
}

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
    "rhel_image" : "ibm-redhat-9-4-amd64-sap-applications-5"
    "sles_image" : "ibm-sles-15-6-amd64-sap-applications-3"
  }
}

variable "network_services_vsi_profile" {
  description = "Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  type        = string
  default     = "cx2-2x4"
}

variable "external_access_ip" {
  description = "Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn."
  type        = string
  default     = "0.0.0.0/0"
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


#####################################################
# Optional Parameters Monitoring and SCC WP Instance
#####################################################

variable "enable_scc_wp" {
  description = "Enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all intel VSIs in this deployment. If set to true, then value for 'ansible_vault_password' in optional parameter must be set."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. If you already have an existing monitoring instance then specify in optional parameter 'existing_monitoring_instance_crn' and setting this parameter to true."
  type        = bool
  default     = false
}

variable "existing_monitoring_instance_crn" {
  description = "Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable_monitoring' is true. "
  type        = string
  default     = null
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

# tflint-ignore: terraform_naming_convention
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace"
  type        = string
  default     = ""
}
