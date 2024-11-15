variable "bastion_host_ip" {
  description = "Jump/Bastion server public IP address to reach the ansible host which has private IP."
  type        = string
}

variable "ansible_host_or_ip" {
  description = "Private IP of virtual server instance running RHEL OS on which ansible will be installed and configured to act as central ansible node."
  type        = string
}

variable "monitoring_vsi_ip" {
  description = "Private IP of virtual server instance  running SLES OS for monitoring services ."
  type        = string
}


variable "ssh_private_key" {
  description = "Private SSH key used to login to jump/bastion server, also the ansible host and all the hosts on which tasks will be executed. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings)."
  type        = string
  sensitive   = true
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


variable "src_script_template_monitoring_name" {
  description = "Name for the bash monitoring file to be generated on the Ansible host."
  type        = string
}

variable "dst_script_file_monitoring_name" {
  description = "Name for the bash monitoring file to be generated on the Ansible host."
  type        = string
}

variable "src_playbook_template_monitoring_name" {
  description = "Name of the playbook template monitoring file located within the 'templates-ansible' directory."
  type        = string
}

variable "dst_playbook_file_monitoring_name" {
  description = "Name for the playbook monitoring file to be generated on the Ansible host."
  type        = string
}
