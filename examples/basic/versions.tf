terraform {
  required_version = ">= 1.3, < 1.5"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.49.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}
