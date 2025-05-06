# IBM Power Virtual Server with VPC Landing Zone

[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-infrastructure?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

## Summary
This repository contains deployable architecture solutions that help provision VPC landing zones, PowerVS workspaces, and interconnect them. The solutions are available in the IBM Cloud Catalog and can also be deployed without the catalog, except for the second solution below.

Four solutions are offered:
1. [Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard)
    - Creates a VPC and Power Virtual Server workspace, interconnects them, and configures OS network management services (SQUID proxy, NTP, NFS, and DNS services) using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
2. [Standard Landscape Extend](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-extend)
    - Extends the standard landscape solution by creating a new Power Virtual Server workspace in a different zone and interconnects with the previous solution.
    - This solution is typically used for **High Availability scenarios** where a single management VPC can be used to reach both PowerVS workspaces.
3. [Quickstart (Standard plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-plus-vsi)
    - Creates a VPC and a Power Virtual Server workspace, interconnects them, and configures operating network management services (SQUID proxy, NTP, NFS, and DNS services) using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
    - Additionally creates a Power Virtual Server Instance of a selected t-shirt size.
    - This solution is typically utilized for **PoCs, demos, and quick onboarding** to PowerVS Infrastructure.
4. [Import Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/import)
    - Takes information about an existing infrastructure and creates a schematics workspace.
    - The schematics workspace's ID and the outputs from it can be used to install the terraform solution 'Power Virtual Server for SAP HANA' on top of a pre-existing PowerVS infrastructure.
    - It creates the ACL and security group rules necessary for management services (NTP, NFS, DNS, and proxy server) and schematics engine access.
    - This solution is typically used for converting an existing Power Virtual Server landscape to a Schematics workspace.

## Reference architectures
- [Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/standard/deploy-arch-ibm-pvs-inf-standard.md)
- [Standard Landscape Extend Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/standard-extend/deploy-arch-ibm-pvs-inf-standard-extend.md)
- [Quickstart (Standard plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/standard-plus-vsi/deploy-arch-ibm-pvs-inf-standard-plus-vsi.md)

## Solutions

| Variation  | Available on IBM Catalog  |  Requires IBM Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard)  | :heavy_check_mark:  | N/A  | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |
| [Standard Landscape Extend](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-extend)    | :heavy_check_mark:  |  :heavy_check_mark: |  N/A | N/A | :heavy_check_mark:  | N/A | N/A |
| [Quickstart (Standard plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-plus-vsi)    | :heavy_check_mark:  |   N/A  | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | N/A |
| [Import Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/import)    | :heavy_check_mark:  |   N/A  | N/A | N/A | N/A  | N/A | N/A |


## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **Workspace for Power Virtual Server** service
        - **Power Virtual Server** service
            - `Editor` platform access
        - **VPC Infrastructure Services** service
            - `Editor` platform access
        - **Transit Gateway** service
            - `Editor` platform access

<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repository. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
