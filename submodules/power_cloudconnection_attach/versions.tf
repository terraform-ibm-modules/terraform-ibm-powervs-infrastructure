#####################################################
# IBM Cloud PowerVS cloud connection Attach Module
#####################################################

terraform {
  required_version = ">=1.2"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.48.0"
    }
  }
}
