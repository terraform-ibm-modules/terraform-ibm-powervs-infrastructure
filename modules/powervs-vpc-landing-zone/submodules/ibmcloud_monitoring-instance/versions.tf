#####################################################
# PowerVS with VPC landing zone module
#####################################################

terraform {
  required_version = ">= 1.3"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.65.0"
    }
  }
}