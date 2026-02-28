#####################################################
# PowerVS standard landscape solution
#####################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.88.3"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "3.0.0"
    }
  }
}
