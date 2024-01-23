# IBM Cloud Solution for Power Virtual Server with VPC Landing Zone Quickstart Variation

This example sets up the following infrastructure:
- A **VPC Infrastructure** with the following components:
     - One VPC with one VSI for management (jump/bastion) using [this preset](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/modules/powervs-vpc-landing-zone/presets/1vpc.preset.json.tftpl).
     - Installation and configuration of Squid Proxy, DNS Forwarder, NTP forwarder, and NFS on the bastion host, and sets the host as the server for the NTP, NFS, and DNS services using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/)

- A **Power Virtual Server** workspace with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Creates one or two IBM Cloud connections in a non-PER environment.
    - Attaches the private networks to the IBM Cloud connections in a non-PER environment.
    - Attaches the IBM Cloud connections to a transit gateway in a non-PER environment.
    - Attaches the PowerVS workspace to Transit gateway in PER-enabled DC
    - Creates an SSH key.

- A PowerVS Instance with following options:
    - t-shirt profile (Aix/IBMi/SAP Image)
    - Custom profile ( cores, memory storage and image)
    - 1 volume

## Solutions
| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Quickstart](./)    | :heavy_check_mark:  |   N/A  | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | N/A |

## Reference architecture
[PowerVS Quickstart variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/quickstart/deploy-arch-ibm-pvs-inf-quickstart.md)

## Architecture diagram
![quickstart-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/quickstart/deploy-arch-ibm-pvs-inf-quickstart.svg)
