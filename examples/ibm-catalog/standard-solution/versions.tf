#####################################################
# powervs service Module
#####################################################

/***************************************************
NOTE: To source a particular version of IBM terraform provider, configure the parameter `version` as follows
terraform {
  required_version = ">=1.1"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "= 1.45.1"
    }
  }
}
If we dont configure the version parameter, it fetches the latest provider version.
****************************************************/

terraform {
  required_version = ">=1.1"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "= 1.45.1"
    }
  }
}
