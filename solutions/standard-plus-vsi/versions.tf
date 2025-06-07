#####################################################
# PowerVS Standard plus VSI solution
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
      version = "2.0.1"
    }
  }
}
