##############################################################################
# Ansible Executor Module - Simplified Variable Interface
##############################################################################

variable "bastion_host_ip" {
  description = "Jump/Bastion server public IP address to reach the ansible host which has private IP."
  type        = string
}

variable "ansible_host_or_ip" {
  description = "Private IP of virtual server instance running RHEL OS on which ansible will be installed and configured to act as central ansible node."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to jump/bastion server, also the ansible host and all the hosts on which tasks will be executed. This key will be written temporarily on ansible host and deleted after execution."
  type        = string
  sensitive   = true
}

variable "configure_ansible_host" {
  description = "If set to true, bash script will be executed to install and configure the collections and packages on ansible node."
  type        = bool
  default     = true
}

variable "ansible_node_config_script" {
  description = "Path to the bash script that configures the ansible host with required packages and collections."
  type        = string
}

variable "ansible_templates" {
  description = "Ansible template configuration including paths to script, playbook, and inventory templates."
  type = object({
    script_template    = string
    playbook_template  = string
    inventory_template = string
  })
}

variable "ansible_files" {
  description = "Destination file names for ansible artifacts on the remote host."
  type = object({
    script_file    = string
    playbook_file  = string
    inventory_file = string
  })
}

variable "ansible_vars" {
  description = "Variables to be passed to ansible templates."
  type = object({
    playbook_vars  = map(any)
    inventory_vars = map(any)
  })
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  default     = null
  validation {
    condition     = var.ansible_vault_password == null ? true : (length(var.ansible_vault_password) >= 15 && length(var.ansible_vault_password) <= 100)
    error_message = "ansible_vault_password needs to be between 15 and 100 characters in length."
  }
  validation {
    condition     = var.ansible_vault_password == null ? true : can(regex("[A-Z]", var.ansible_vault_password))
    error_message = "ansible_vault_password needs to contain at least one uppercase character (A-Z)."
  }
  validation {
    condition     = var.ansible_vault_password == null ? true : can(regex("[a-z]", var.ansible_vault_password))
    error_message = "ansible_vault_password needs to contain at least one lowercase character (a-z)."
  }
  validation {
    condition     = var.ansible_vault_password == null ? true : can(regex("[0-9]", var.ansible_vault_password))
    error_message = "ansible_vault_password needs to contain at least one number (0-9)."
  }
  validation {
    condition     = var.ansible_vault_password == null ? true : can(regex("[!#$%&()*+\\-.:;<=>?@[\\]_{|}~]", var.ansible_vault_password))
    error_message = "ansible_vault_password needs to contain at least one of the following special characters: !#$%&()*+-.:;<=>?@[]_{|}~"
  }
  validation {
    condition     = var.ansible_vault_password == null ? true : can(regex("^[A-Za-z0-9!#$%&()*+\\-.:;<=>?@[\\]_{|}~]+$", var.ansible_vault_password))
    error_message = "ansible_vault_password contains illegal characters. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~"
  }
}

variable "enable_playbook_encryption" {
  description = "Whether to encrypt the playbook file using ansible vault."
  type        = bool
  default     = false
}

variable "enable_ocp_config_encryption" {
  description = "Whether to encrypt/decrypt OCP config files. Only applicable for OpenShift deployments."
  type        = bool
  default     = false
}

variable "enable_api_key_redaction" {
  description = "Whether to redact IBM Cloud API keys from logs. Only applicable when ibmcloud_api_key is provided."
  type        = bool
  default     = false
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources. Only required for OpenShift deployments."
  type        = string
  sensitive   = true
  default     = null
}

variable "ocp_cluster_dir" {
  description = "Directory path for OpenShift cluster installation files. Only applicable for OpenShift deployments."
  type        = string
  default     = "/tmp"
}
