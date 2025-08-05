#####################################################
# PowerVS Standard plus VSI solution
#####################################################

terraform {
  required_version = ">= 1.9"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.81.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
    # time = {
    #   source  = "hashicorp/time"
    #   version = "0.13.1"
    # }

  }
}
