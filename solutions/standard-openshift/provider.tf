locals {
  ibm_powervs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "sao01"    = "sao"
    "sao04"    = "sao"
    "sao05"    = "sao"
    "tor01"    = "tor"
    "mon01"    = "mon"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "mad02"    = "mad"
    "mad04"    = "mad"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "dal14"    = "us-south"
    "us-east"  = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }

  ibm_powervs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "sao01"    = "br-sao"
    "sao04"    = "br-sao"
    "sao05"    = "br-sao"
    "tor01"    = "ca-tor"
    "mon01"    = "ca-tor"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "mad02"    = "eu-es"
    "mad04"    = "eu-es"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "osa21"    = "jp-osa"
    "tok04"    = "jp-tok"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "dal14"    = "us-south"
    "us-east"  = "us-east"
    "wdc06"    = "us-east"
    "wdc07"    = "us-east"
  }

  openshift_region_map = {
    "syd04" = "syd"
    "syd05" = "syd"
    "sao01" = "sao"
    "sao04" = "sao"
    "sao05" = "sao"
    "tor01" = "tor"
    #"mon01"    = "ca-tor"
    "eu-de-1" = "eu-de"
    "eu-de-2" = "eu-de"
    "mad02"   = "mad"
    "mad04"   = "mad"
    "lon04"   = "lon"
    "lon06"   = "lon"
    "osa21"   = "osa"
    #"tok04"    = "jp-tok"
    "us-south" = "us-south"
    "dal10"    = "dal"
    "dal12"    = "dal"
    "us-east"  = "us-east"
    "wdc06"    = "wdc"
    "wdc07"    = "wdc"
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

provider "ibm" {
  alias            = "ibm-sm"
  region           = var.existing_sm_instance_region == null ? lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null) : var.existing_sm_instance_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_iam_auth_token" "auth_token" {
  provider = ibm.ibm-is
}

provider "restapi" {
  uri = "https://resource-controller.cloud.ibm.com"
  headers = {
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}
