#####################################################
# PowerVS standard landscape solution
#####################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.78.3"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">=1.20.0, <2.0.0"
    }
  }
}
