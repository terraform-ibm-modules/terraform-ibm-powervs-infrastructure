variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
}

variable "tshirt_size" {
  description = "PowerVS instance profiles. These profiles can be overridden by specifying 'custom_profile_instance_boot_image' and 'custom_profile' values in optional parameters."
  type        = string

  validation {
    condition     = contains(["custom", "aix_xs", "aix_s", "aix_m", "aix_l", "ibm_i_xs", "ibm_i_s", "ibm_i_m", "ibm_i_l", "sap_dev_rhel", "sap_dev_sles"], var.tshirt_size)
    error_message = "Only Following DC values are supported :  custom, aix_xs, aix_s, aix_m, aix_l, ibm_i_xs, ibm_i_s, ibm_i_m, ibm_i_l, sap_dev_rhel, sap_dev_sles"
  }
}

variable "external_access_ip" {
  description = "Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn."
  type        = string
}

variable "client_to_site_vpn" {
  description = "VPN configuration - the client ip pool, existing instance id(guid) of the secrets manager, CRN of the uploaded VPN server certificate in secrets manager and list of users email ids to access the environment."
  type = object({
    enable                        = bool
    client_ip_pool                = string
    secrets_manager_id            = string
    server_cert_crn               = string
    vpn_client_access_group_users = list(string)
  })

  default = {
    "enable" : false,
    "client_ip_pool" : "192.168.0.0/16",
    "secrets_manager_id" : "",
    "server_cert_crn" : "",
    "vpn_client_access_group_users" : [""]
  }
}

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to public SSH key referenced by 'ssh_public_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

#####################################################
# Optional Parameters
#####################################################

variable "custom_profile_instance_boot_image" {
  description = "Override the t-shirt size specs of PowerVS Workspace instance by selecting an image name and providing valid 'custom_profile' optional parameter."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["RHEL9-SP2-SAP", "RHEL8-SP8-SAP", "RHEL9-SP2-SAP-NETWEAVER", "RHEL8-SP8-SAP-NETWEAVER", "SLES15-SP5-SAP", "SLES15-SP4-SAP", "SLES15-SP5-SAP-NETWEAVER", "SLES15-SP4-SAP-NETWEAVER", "7300-02-01", "7200-05-07", "IBMi-75-03-2924-1", "IBMi-75-03-2984-1", "IBMi-74-09-2984-1", "IBMi_COR-74-09-1", "none"], var.custom_profile_instance_boot_image)
    error_message = "Only Following IBM catalog images are supported :  RHEL9-SP2-SAP, RHEL9-SP2-SAP-NETWEAVER, RHEL8-SP8-SAP, RHEL8-SP8-SAP-NETWEAVER, SLES15-SP5-SAP, SLES15-SP4-SAP,  SLES15-SP5-SAP-NETWEAVER, SLES15-SP4-SAP-NETWEAVER, 7300-02-01, 7200-05-07, IBMi-75-03-2924-1, IBMi-75-03-2984-1, IBMi-74-09-2984-1, IBMi_COR-74-09-1, none"
  }
}

variable "custom_profile" {
  description = "Overrides t-shirt profile: Custom PowerVS instance. Specify 'sap_profile_id' [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs) or combination of 'cores' & 'memory'. Optionally volumes can be created."
  type = object({
    sap_profile_id = string
    cores          = string
    memory         = string
    server_type    = string
    proc_type      = string
    storage = object({
      size = string
      tier = string
    })
  })
  default = {
    "sap_profile_id" : null,
    "cores" : "",
    "memory" : "",
    "server_type" : "",
    "proc_type" : "",
    "storage" : {
      "size" : "",
      "tier" : ""
    }
  }

  validation {
    condition     = (((var.custom_profile.sap_profile_id == null || var.custom_profile.sap_profile_id == "") && ((var.custom_profile.cores == "" && var.custom_profile.memory == "" && var.custom_profile.proc_type == "" && var.custom_profile.server_type == "") || (var.custom_profile.cores != "" && var.custom_profile.memory != "" && var.custom_profile.server_type != "" && var.custom_profile.proc_type != ""))) || (var.custom_profile.sap_profile_id != null && (var.custom_profile.cores == "" && var.custom_profile.memory == "" && var.custom_profile.proc_type == "" && var.custom_profile.server_type == "")))
    error_message = "Invalid custom config. If 'sap_profile_id' is not null or empty, then cores, memory, server_type and proc_type must be empty."
  }
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
}

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

#############################################################################
# Schematics Output
#############################################################################

# tflint-ignore: terraform_naming_convention
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace"
  type        = string
  default     = ""
}
