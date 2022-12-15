#####################################################
# IBM Cloud PowerVS cloud connection create Module
#####################################################

terraform {
  required_version = ">=1.2"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
