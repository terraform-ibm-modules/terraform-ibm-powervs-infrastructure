variable "access_host_or_ip" {
  description = "Jump/Bastion server public IP address to reach the ansible host which has private IP."
  type        = string
}

variable "ansible_host_or_ip" {
  description = "Private IP of virtual server instance on which ansible will be installed and configured to act as central ansible node."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to jump/bastion server and also the ansible host .Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). This key will be written temprarily on ansible host and deleted after execution."
  type        = string
  sensitive   = true
}

variable "network_services_config" {
  description = "An object which contains configuration for NFS, NTP, DNS, Squid Services."
  type        = any
  default     = {}
}
