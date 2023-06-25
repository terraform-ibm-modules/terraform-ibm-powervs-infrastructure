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
  default     = "sap_dev"

  validation {
    condition     = contains(["aix_xs", "aix_s", "aix_m", "aix_l", "ibm_i_xs", "ibm_i_s", "ibm_i_m", "ibm_i_l", "sap_dev", "sap_olap", "sap_oltp"], var.tshirt_size)
    error_message = "Only Following DC values are supported :  aix_xs, aix_s, aix_m, aix_l, ibm_i_xs, ibm_i_s, ibm_i_m, ibm_i_l, sap_dev, sap_olap, sap_oltp"
  }
}

variable "external_access_ip" {
  description = "Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to public SSH key referenced by 'ssh_public_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
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
  description = "Override the t-shirt size specs of PowerVS Workspace instance by selecting an image name and providing valid custom_profile parameter."
  type        = string
  default     = "RHEL8-SP4-SAP"
  validation {
    condition     = contains(["RHEL8-SP4-SAP", "SLES15-SP4-SAP", "RHEL8-SP4-SAP-NETWEAVER", "SLES15-SP4-SAP-NETWEAVER", "IBMi-73-13-2924-1", "IBMi-74-07-2924-1", "IBMi-75-01-2924-2", "IBMi_COR-74-07-2", "7300-01-01", "7300-00-01", "7200-05-03", ""], var.custom_profile_instance_boot_image)
    error_message = "Only Following DC values are supported :  RHEL8-SP4-SAP, SLES15-SP4-SAP, RHEL8-SP4-SAP-NETWEAVER, SLES15-SP4-SAP-NETWEAVER, IBMi-73-13-2924-1, IBMi-74-07-2924-1, IBMi-75-01-2924-2, IBMi_COR-74-07-2, 7300-01-01, 7300-00-01, 7200-05-03"
  }
}

variable "custom_profile" {
  description = "Overrides t-shirt profile: Custom PowerVS instance. Specify 'sap_profile_id' [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs) or combination of 'cores' & 'memory'. Optionally volumes can be created."
  type = object({
    sap_profile_id = string
    cores          = string
    memory         = string
    storage        = object({ size = string, tier = string })
  })
  default = {
    sap_profile_id = null
    cores          = ""
    memory         = ""
    storage        = { size = "", tier = "" }

  }

  validation {
    condition     = (((var.custom_profile.sap_profile_id == null || var.custom_profile.sap_profile_id == "") && ((var.custom_profile.cores == "" && var.custom_profile.memory == "") || (var.custom_profile.cores != "" && var.custom_profile.memory != ""))) || (var.custom_profile.sap_profile_id != null && (var.custom_profile.cores == "" && var.custom_profile.memory == "")))
    error_message = "Invalid custom config. If 'sap_profile_id' is not null or empty, cores and memory should be empty."
  }
}

variable "configure_dns_forwarder" {
  description = "Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns_forwarder_config' optional variable is set properly. DNS forwarder will be installed on the private-svs vsi."
  type        = bool
  default     = true
}

variable "configure_ntp_forwarder" {
  description = "Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the private-svs vsi."
  type        = bool
  default     = true
}

variable "configure_nfs_server" {
  description = "Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). NFS server will be installed on the private-svs vsi."
  type        = bool
  default     = true
}

variable "dns_forwarder_config" {
  description = "Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS."
  type = object({
    dns_servers = string
  })
  default = {
    "dns_servers" = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "powervs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create."
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "mgmt_net"
    cidr = "10.51.0.0/24"
  }
}

variable "powervs_backup_network" {
  description = "Name of the IBM Cloud PowerVS backup network and CIDR to create."
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "bkp_net"
    cidr = "10.52.0.0/24"
  }
}

variable "cloud_connection" {
  description = "Cloud connection configuration: speed (50, 100, 200, 500, 1000, 2000, 5000, 10000 Mb/s), count (1 or 2 connections), global_routing (true or false), metered (true or false)"
  type = object({
    count          = number
    speed          = number
    global_routing = bool
    metered        = bool
  })

  default = {
    count          = 2
    speed          = 5000
    global_routing = true
    metered        = true
  }
}

variable "powervs_image_names" {
  description = "List of Images to be imported into cloud account from catalog images"
  type        = list(string)
  default     = ["IBMi-73-13-2924-1", "7300-01-01", "RHEL8-SP4-SAP"]
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
  default     = "Default"
}

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS workspace"
  type        = list(string)
  default     = ["demo"]
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
