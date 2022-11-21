prerequisite_workspace_id = "###ws-id###"
powervs_zone              = "###pvs-zone###"

ibmcloud_api_key            = "###apikey###" #pragma: allowlist secret
powervs_resource_group_name = "Automation"   # existing resource group name

powervs_management_network = {
  name                = "mgmt_net"
  cidr                = "10.34.0.0/24"
  starting_ip_address = ""
  ending_ip_address   = ""
}

powervs_backup_network = {
  name                = "bkp_net"
  cidr                = "10.35.0.0/24"
  starting_ip_address = ""
  ending_ip_address   = ""
}

tags = ["T1", "T2"]

cloud_connection_count   = "2"   ### 1 or 2 depending on availability in DC. Per DC max count is 2
cloud_connection_speed   = 5000  ### mandatory
cloud_connection_gr      = true  # optional
cloud_connection_metered = false # optional
reuse_cloud_connections  = false
