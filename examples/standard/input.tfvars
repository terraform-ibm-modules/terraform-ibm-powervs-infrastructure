#####################################################
# Powervs Infrastructure SAP Standard input vars file Example
#####################################################

/****************************************************
Example 1 usage with new cloud connection:

ibmcloud_api_key              = "<ibmcloud-api-key>"
powervs_zone                      = "dal12"
powervs_resource_group_name       = "Automation" # existing resource group name
prefix                        = "test"
tags                          = ["sap"]

powervs_management_network = {
  name = "mgmt_net"
  cidr = "10.71.0.0/24"
}
powervs_backup_network = {
  name = "bkp_net"
  cidr = "10.72.0.0/24"
}

transit_gateway_name          = "<name>" # existing transit gateway name
reuse_cloud_connections       = false
cloud_connection_count        = 2    ### 1 or 2 depending on availability in DC. Per DC max count is 2
cloud_connection_speed        = 5000 ### mandatory
cloud_connection_gr           = true   # optional
cloud_connection_metered      = false  # optional

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

******************************************************/

/****************************************************
Example 2 usage with reusing cloud connection:

ibmcloud_api_key              = "<ibmcloud-api-key>"
powervs_zone                  = "dal12"
powervs_resource_group_name   = "Automation" # existing resource group name
prefix                        = "test"

powervs_management_network = {
  name = "mgmt_net"
  cidr = "10.71.0.0/24"
}

powervs_backup_network = {
  name = "bkp_net"
  cidr = "10.72.0.0/24"
}

tags                          = ["T1", "T2"]
reuse_cloud_connections       = true

access_host_or_ip             = "169.48.155.49"
internet_services_host_or_ip  = "10.30.10.4"
private_services_host_or_ip   = "10.20.10.4"
configure_proxy               = false
configure_ntp_forwarder       = false
configure_nfs_server          = false
configure_dns_forwarder       = false
ssh_public_key                = "<value>"
ssh_private_key               = <<-EOF
<value>
EOF

******************************************************/
