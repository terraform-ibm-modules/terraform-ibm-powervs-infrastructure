# IBM Cloud catalog solution for Power Virtual Server with VPC landing zone Extension Variation

This example extends an existing PowerVS infrastructure for deployable architectures deployed as full-stack with an additional PowerVS workspace.
It provisions the following infrastructure on top of deployed Full Stack solution :

- A **Power Virtual Server workspace** with the following network topology:
    - Creates two private networks: a management network and a backup network
    - Creates one or two IBM Cloud connections in Non PER environment.
    - Attaches the private networks to the IBM Cloud connections in Non PER environment.
    - Attaches the IBM Cloud connections to a transit gateway in Non PER environment.
    - Attaches the PowerVS workspace to Transit gateway in PER enabled DC
    - Creates an SSH key.


### Notes:
- Kindly make sure that you are **choosing a PowerVS zone different** from that of the pre-requisite infrastructure.
- **This solution requires a schematics workspace id as an input.**
- Catalog image names to be imported into infrastructure can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/solutions/full-stack/docs/catalog_image_names.md)

### Before you begin

If you do not have a PowerVS infrastructure that is the [full stack solution](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/full-stack) for a PowerVS Workspace that includes the full stack solution for Secure Landing Zone, create it first.


| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Extension](./)    | :heavy_check_mark:  |  :heavy_check_mark: |  N/A | N/A | :heavy_check_mark:  | N/A | N/A |


## Reference architecture
[PowerVS workspace extension variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/extension/deploy-arch-ibm-pvs-inf-extension.md)

## Architecture diagram
![extension-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/extension/deploy-arch-ibm-pvs-inf-extension.svg)
