#####################################################
# IBM Cloud PowerVS sworkspace Module
#####################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "=1.50.0"
    }
  }
}
