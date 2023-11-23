#####################################################
# IBM Cloud PowerVS workspace Module
#####################################################

terraform {
  required_version = ">= 1.3"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.58.1"
      #configuration_aliases = [ibm.ibm-pi]
    }
  }
}
