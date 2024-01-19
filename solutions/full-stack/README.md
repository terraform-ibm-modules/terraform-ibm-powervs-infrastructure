# IBM Cloud solution for Power Virtual Server with VPC landing zone Full-Stack Variation

This example sets up the following infrastructure:
- A **VPC Infrastructure** with the following components:
    -  Provisions three VPCs with one VSI in each VPC (one management(jump/bastion) VSI, one inet-svs VSI configured as squid proxy server, one private-svs VSI configured as NFS, NTP, DNS server).
    - Installs and configures the Squid Proxy, DNS Forwarder, NTP forwarder and NFS on hosts, and sets the host as the server for the NTP, NFS, and DNS services using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).

- A **Power Virtual Server** workspace with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Creates one or two IBM Cloud connections in Non PER environment.
    - Attaches the private networks to the IBM Cloud connections in Non PER environment.
    - Attaches the IBM Cloud connections to a transit gateway in Non PER environment.
    - Attaches the PowerVS workspace to Transit gateway in PER enabled DC
    - Creates an SSH key.

### Notes:
- Catalog image names to be imported into infrastructure can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/solutions/full-stack/docs/catalog_image_names.md)

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Full-Stack](./)  | :heavy_check_mark:  | N/A  | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |



## Reference architecture
[PowerVS workspace full-stack variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.md)


## Architecture diagram
![full-stack-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.svg)
