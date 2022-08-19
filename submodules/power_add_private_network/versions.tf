#####################################################
# IBM Cloud PowerVS service Module
#####################################################

terraform {
  required_version = ">=1.1"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.43.0"
    }
  }
}
