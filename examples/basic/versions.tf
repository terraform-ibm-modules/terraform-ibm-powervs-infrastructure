terraform {
  required_version = ">=1.1"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "= 1.45.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.2"
    }
  }
}
