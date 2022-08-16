variable "access_host_or_ip" {
  description = "Jump/Bastion server Public IP to reach the target/server_host ip to configure the DNS,NTP,NFS,SQUID services"
  type        = string
}

variable "target_server_ip" {
  description = "Target/server_host ip on which the DNS,NTP,NFS,SQUID services will be configured."
  type        = string
}

variable "ssh_private_key" {
  description = "SSh private key value to login to server. It will not be uploaded / stored anywhere."
  type        = string
}

variable "service_config" {
  description = "Name of the existing transit gateway. Required when creating new cloud connections"
  type        = map(any)
  default     = {}
}
