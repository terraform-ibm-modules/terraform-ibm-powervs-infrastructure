#####################################################
# PowerVS with VPC landing zone module
#####################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    ibm = {
      source                = "IBM-Cloud/ibm"
      version               = ">=1.65.0"
      configuration_aliases = [ibm.ibm-is, ibm.ibm-pi, ibm.ibm-sm]
    }
  }
}
