locals {
  ibm_powervs_zone_region_map = {
    "lon04"    = "lon"
    "lon06"    = "lon"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "tor01"    = "tor"
    "mon01"    = "mon"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "syd04"    = "syd"
    "syd05"    = "syd"
    "sao01"    = "sao"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
  }
}

provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

locals {
  location = regex("^[a-z/-]+", var.prerequisite_workspace_id)
}

data "ibm_schematics_workspace" "schematics_workspace" {
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
}

data "ibm_schematics_output" "schematics_output" {
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}


locals {

  fullstack_output     = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
  prefix               = local.fullstack_output[0].prefix.value
  ssh_public_key       = local.fullstack_output[0].ssh_public_key.value
  transit_gateway_name = local.fullstack_output[0].transit_gateway_name.value
  transit_gateway_id   = local.fullstack_output[0].transit_gateway_id.value

  access_host_or_ip_exists   = contains(keys(local.fullstack_output[0]), "access_host_or_ip") ? true : false
  access_host_or_ip          = local.access_host_or_ip_exists ? local.fullstack_output[0].access_host_or_ip.value : ""
  proxy_host_or_ip_exists    = contains(keys(local.fullstack_output[0]), "proxy_host_or_ip_port") && local.access_host_or_ip != "" ? true : false
  proxy_host_or_ip           = local.proxy_host_or_ip_exists ? split(":", local.fullstack_output[0].proxy_host_or_ip_port.value)[0] : ""
  squid_port                 = local.proxy_host_or_ip_exists ? split(":", local.fullstack_output[0].proxy_host_or_ip_port.value)[1] : ""
  dns_host_or_ip_exists      = contains(keys(local.fullstack_output[0]), "dns_host_or_ip") && local.access_host_or_ip != "" ? true : false
  dns_host_or_ip             = local.dns_host_or_ip_exists ? local.fullstack_output[0].dns_host_or_ip.value : ""
  nfs_host_or_ip_path_exists = contains(keys(local.fullstack_output[0]), "nfs_host_or_ip_path") && local.access_host_or_ip != "" ? true : false
  nfs_host_or_ip             = local.nfs_host_or_ip_path_exists && local.fullstack_output[0].nfs_host_or_ip_path.value != "" ? split(":", local.fullstack_output[0].nfs_host_or_ip_path.value)[0] : ""
  nfs_path                   = local.nfs_host_or_ip_path_exists && local.fullstack_output[0].nfs_host_or_ip_path.value != "" ? split(":", local.fullstack_output[0].nfs_host_or_ip_path.value)[1] : ""
  ntp_host_or_ip_exists      = contains(keys(local.fullstack_output[0]), "ntp_host_or_ip") && local.access_host_or_ip != "" ? true : false
  ntp_host_or_ip             = local.ntp_host_or_ip_exists ? local.fullstack_output[0].ntp_host_or_ip.value : ""

  valid_powervs_zone_used   = local.fullstack_output[0].powervs_zone != var.powervs_zone ? true : false
  validate_powervs_zone_msg = "A Power workspace already exists in the provided PowerVS zone. Please use a different zone."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_powervs_zone_msg}$", (local.valid_powervs_zone_used ? local.validate_powervs_zone_msg : ""))

  fullstack_mgt_net       = local.fullstack_output[0].powervs_management_network_subnet.value
  fullstack_bkp_net       = local.fullstack_output[0].powervs_backup_network_subnet.value
  valid_mgt_subnet_used   = local.fullstack_mgt_net != var.powervs_management_network["cidr"] ? true : false
  validate_mgt_subnet_msg = "This management subnet CIDR already exists in the infrastructure. Please use another CIDR block."
  # tflint-ignore: terraform_unused_declarations
  validate_mgt_subnet_chk = regex("^${local.validate_mgt_subnet_msg}$", (local.valid_mgt_subnet_used ? local.validate_mgt_subnet_msg : ""))

  valid_bkp_subnet_used   = local.fullstack_bkp_net != var.powervs_backup_network["cidr"] ? true : false
  validate_bkp_subnet_msg = "This backup subnet CIDR already exists in the infrastructure. Please use another CIDR block."
  # tflint-ignore: terraform_unused_declarations
  validate_bkp_subnet_chk = regex("^${local.validate_bkp_subnet_msg}$", (local.valid_bkp_subnet_used ? local.validate_bkp_subnet_msg : ""))
}

module "powervs_infra" {
  source = "../../"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = "${local.prefix}-${var.powervs_zone}-power-workspace"
  tags                        = var.tags
  powervs_image_names         = var.powervs_image_names
  powervs_sshkey_name         = "${local.prefix}-${var.powervs_zone}-ssh-pvs-key"
  ssh_public_key              = local.ssh_public_key
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  transit_gateway_id          = local.transit_gateway_id
  cloud_connection_count      = var.cloud_connection["count"]
  cloud_connection_speed      = var.cloud_connection["speed"]
  cloud_connection_gr         = var.cloud_connection["global_routing"]
  cloud_connection_metered    = var.cloud_connection["metered"]
}
