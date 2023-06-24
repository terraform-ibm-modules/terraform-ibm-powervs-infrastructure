#####################################################
# IBM Cloud PowerVS workspace Module
#####################################################

terraform {
  required_version = ">= 1.3, < 1.6"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.49.0"
    }
  }
}
