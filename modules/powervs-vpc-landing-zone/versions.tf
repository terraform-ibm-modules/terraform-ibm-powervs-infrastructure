#####################################################
# PowerVS with VPC landing zone module
#####################################################

terraform {
  required_version = ">= 1.3"
  required_providers {
    ibm = {
      source                = "IBM-Cloud/ibm"
      version               = ">=1.61.0"
      configuration_aliases = [ibm.ibm-is, ibm.ibm-pi]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
