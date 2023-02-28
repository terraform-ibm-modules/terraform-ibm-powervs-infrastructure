#####################################################
# Powervs Infrastructure SAP Standard input vars file Example
#####################################################

/****************************************************
##Example 1 usage with new cloud connection:

ibmcloud_api_key              = "<ibmcloud-api-key>"
powervs_zone                  = "syd04"
powervs_resource_group_name   = "<resource-group-name>" # existing resource group name
prefix                        = "<prefix-name>"
transit_gateway_name          = "<existing-tg-name>" # existing transit gateway name
access_host_or_ip             = "<ip>"
internet_services_host_or_ip  = "<ip>"
private_services_host_or_ip   = "<ip>"
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
##Example 2 usage with reusing cloud connection:

ibmcloud_api_key              = "<ibmcloud-api-key>"
powervs_zone                  = "syd04"
powervs_resource_group_name   = "<resource-group-name>" # existing resource group name
prefix                        = "<prefix-name>"
reuse_cloud_connections       = true
access_host_or_ip             = "<ip>"
internet_services_host_or_ip  = "<ip>"
private_services_host_or_ip   = "<ip>"
configure_proxy               = true
configure_ntp_forwarder       = true
configure_nfs_server          = true
configure_dns_forwarder       = true
ssh_public_key                = "<value>"
ssh_private_key               = <<-EOF
<value>
EOF

******************************************************/
