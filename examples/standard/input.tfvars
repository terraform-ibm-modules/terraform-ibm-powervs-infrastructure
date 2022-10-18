#####################################################
# Powervs Infrastructure SAP Standard input vars file Example
#####################################################

/****************************************************
##Example 1 usage with new cloud connection:

ibmcloud_api_key              = "<ibmcloud-api-key>"
powervs_zone                  = "syd04"
powervs_resource_group_name   = "<resource-group-name>" # existing resource group name
prefix                        = "<prefix-name>"

powervs_management_network = {
  name = "mgmt_net"
  cidr = "10.71.0.0/24"
}
powervs_backup_network = {
  name = "bkp_net"
  cidr = "10.72.0.0/24"
}
transit_gateway_name          = "<existing-tg-name>" # existing transit gateway name
reuse_cloud_connections       = false
cloud_connection_count        = 2    ### 1 or 2 depending on availability in DC. Per DC max count is 2
cloud_connection_speed        = 5000 ### mandatory

access_host_or_ip             = "52.118.147.77"
internet_services_host_or_ip  = "10.30.10.4"
private_services_host_or_ip   = "10.20.10.4"
configure_proxy               = true
configure_ntp_forwarder       = true
configure_nfs_server          = true
configure_dns_forwarder       = true
ssh_public_key                = "<value>"
ssh_private_key               = <<-EOF
<value>
EOF

####optional####
cloud_connection_gr           = true   # optional
cloud_connection_metered      = false  # optional
tags                          = ["sap"] # optional



******************************************************/

/****************************************************
##Example 2 usage with reusing cloud connection:

ibmcloud_api_key              = "<ibmcloud-api-key>"
powervs_zone                  = "syd04"
powervs_resource_group_name   = "<resource-group-name>" # existing resource group name
prefix                        = "<prefix-name>"

powervs_management_network = {
  name = "mgmt_net"
  cidr = "10.71.0.0/24"
}
powervs_backup_network = {
  name = "bkp_net"
  cidr = "10.72.0.0/24"
}
reuse_cloud_connections       = true

access_host_or_ip             = "169.48.155.49"
internet_services_host_or_ip  = "10.30.10.4"
private_services_host_or_ip   = "10.20.10.4"
configure_proxy               = true
configure_ntp_forwarder       = true
configure_nfs_server          = true
configure_dns_forwarder       = true
ssh_public_key                = "<value>"
ssh_private_key               = <<-EOF
<value>
EOF

####optional####
tags                          = ["sap"] # optional

******************************************************/
