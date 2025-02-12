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
}

variable "src_script_template_name" {
  description = "Name of the bash script template file located within the 'templates-ansible' directory."
  type        = string
}

variable "dst_script_file_name" {
  description = "Name for the bash file to be generated on the Ansible host."
  type        = string
}

variable "src_playbook_template_name" {
  description = "Name of the playbook template file located within the 'templates-ansible' directory."
  type        = string
}

variable "dst_playbook_file_name" {
  description = "Name for the playbook file to be generated on the Ansible host."
  type        = string
}

variable "playbook_template_vars" {
  description = "Map values for the ansible playbook template."
  type        = map(any)
}

variable "src_inventory_template_name" {
  description = "Name of the inventory template file located within the 'templates-ansible' directory."
  type        = string
}

variable "dst_inventory_file_name" {
  description = "Name for the inventory file to be generated on the Ansible host."
  type        = string
}

variable "inventory_template_vars" {
  description = "Map values for the inventory template."
  type        = map(any)
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
