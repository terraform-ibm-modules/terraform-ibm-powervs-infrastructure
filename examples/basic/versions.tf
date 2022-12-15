terraform {
  required_version = ">=1.2"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "=1.48.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}
