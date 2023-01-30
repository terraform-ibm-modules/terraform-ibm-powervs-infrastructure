variable "access_host_or_ip" {
  description = "Jump/Bastion server Public IP to reach the target/server_host ip to configure the DNS,NTP,NFS,SQUID services"
  type        = string
}

variable "target_server_ip" {
  description = "Target/server_host ip on which the DNS,NTP,NFS,SQUID services will be configured."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to IBM PowerVS instances.Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored."
  type        = string
  sensitive   = true
}

variable "service_config" {
  description = "An object which contains configuration for NFS, NTP, DNS, Squid Services"
  type        = any
  default     = {}
}

variable "perform_proxy_client_setup" {
  description = "Configures a Vm/Lpar to have internet access by setting proxy on it."
  type = object(
    {
      squid_client_ips = list(string)
      squid_server_ip  = string
      squid_port       = string
      no_proxy_hosts   = string
    }
  )
}
