locals {
  ibm_powervs_zone_region_map = {
    "syd04"   = "syd"
    "syd05"   = "syd"
    "sao01"   = "sao"
    "sao04"   = "sao"
    "tor01"   = "tor"
    "mon01"   = "mon"
    "eu-de-1" = "eu-de"
    "eu-de-2" = "eu-de"
    #"mad02"    = "mad" #not supported. Just P10 machines
    #"mad04"    = "mad" #not supported. Just P10 machines
    "lon04"    = "lon"
    "lon06"    = "lon"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }

  ibm_powervs_zone_cloud_region_map = {
    "syd04"   = "au-syd"
    "syd05"   = "au-syd"
    "sao01"   = "br-sao"
    "sao04"   = "br-sao"
    "tor01"   = "ca-tor"
    "mon01"   = "ca-tor"
    "eu-de-1" = "eu-de"
    "eu-de-2" = "eu-de"
    #"mad02"    = "eu-es" #not supported. Just P10 machines
    #"mad04"    = "eu-es" #not supported. Just P10 machines
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "osa21"    = "jp-osa"
    "tok04"    = "jp-tok"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }
}

# There are discrepancies between the region inputs on the powervs terraform resource, and the vpc ("is") resources
provider "ibm" {
  alias            = "ibm-pi"
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-is"
  region           = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}
