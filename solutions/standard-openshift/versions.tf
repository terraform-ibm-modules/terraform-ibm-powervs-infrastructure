#####################################################
# PowerVS Quickstart OpenShift solution
#####################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.87.2"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
  }
}
