#####################################################
# IBM Cloud PowerVS service Module
#####################################################

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.44.3"
    }
  }
}
