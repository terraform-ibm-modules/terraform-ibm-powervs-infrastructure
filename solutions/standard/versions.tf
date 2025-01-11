#####################################################
# PowerVS Standard solution
#####################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.74.0"
    }
  }
}
