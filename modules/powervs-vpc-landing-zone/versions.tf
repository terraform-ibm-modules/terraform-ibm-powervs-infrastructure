#####################################################
# powervs service Module
#####################################################

terraform {
  required_version = ">= 1.3, < 1.6"
  required_providers {
    ibm = {
      source                = "IBM-Cloud/ibm"
      version               = ">=1.58.1"
      configuration_aliases = [ibm.ibm-is, ibm.ibm-pi]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
