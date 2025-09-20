#####################################################
# DNS Service & Zone Creation
#####################################################

resource "ibm_resource_instance" "ibm_dns_instance" {
  provider = ibm.ibm-is
  count    = var.ibm_dns_service.enable ? 1 : 0

  name              = var.ibm_dns_service.name
  resource_group_id = module.landing_zone.resource_group_data["${var.prefix}-${local.second_rg_name}"]
  location          = "global"
  service           = "dns-svcs"
  plan              = "standard-dns"
}

resource "ibm_dns_zone" "dns_zone" {
  provider = ibm.ibm-is
  count    = var.ibm_dns_service.enable ? 1 : 0

  name        = var.ibm_dns_service.base_domain
  instance_id = ibm_resource_instance.ibm_dns_instance[0].guid
  description = "IBM DNS instance created by deployable architecture for OpenShift IPI on Power Virtual Server"
  label       = var.ibm_dns_service.label
}

resource "ibm_dns_custom_resolver" "dns_resolver" {
  provider = ibm.ibm-is
  count    = var.ibm_dns_service.enable ? 1 : 0

  name                     = "${var.ibm_dns_service.name}-resolver"
  instance_id              = ibm_resource_instance.ibm_dns_instance[0].guid
  description              = "IBM DNS custom resolver for OpenShift IPI on Power Virtual Server"
  high_availability        = true
  enabled                  = true
  profile                  = "essential"
  allow_disruptive_updates = false
  locations {
    subnet_crn = module.landing_zone.vpc_data[0].subnet_detail_map["zone-1"][0].crn
    enabled    = true
  }
  locations {
    subnet_crn = module.landing_zone.vpc_data[0].subnet_detail_map["zone-1"][1].crn
    enabled    = true
  }
  locations {
    subnet_crn = module.landing_zone.vpc_data[0].subnet_detail_map["zone-1"][2].crn
    enabled    = true
  }
}
