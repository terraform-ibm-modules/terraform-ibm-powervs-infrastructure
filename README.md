<!-- BEGIN MODULE HOOK -->

# IBM Power Virtual Server with VPC landing zone

[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-infrastructure?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

## Summary
This repository contains deployable architecture solutions which helps in provisioning VPC landing zone, PowerVS workspace and interconnecting them. The solutions are available in IBM Cloud Catalog and also can be deployed without catalog as well except the second solution below.

Three solutions are offered:
1. [PowerVS full-stack variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/full-stack)
    - Creates three VPCs with RHEL or SLES instances, Power Virtual Server workspace, interconnects them and configures os network management services(SQUID proxy, NTP, NFS, and DNS services) using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
2. [PowerVS extension variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/extension)
    - Extends the full-stack solution by creating a new Power Virtual Server workspace in different zone and interconnects with the previous solution.
    - This solution is typically used for **High Availability scenarios** where a single management VPCs can be used to reach both PowerVS workspaces.
3. [PowerVS quickstart variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/quickstart)
    - Creates 1VPC and a Power Virtual Server workspace, interconnects them and configures os network management services(SQUID proxy, NTP, NFS, and DNS services) using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
    - Additionally creates a Power Virtual Server Instance of selected t-shirt size.
    - This solution is typically used for **PoCs, demos and quick onboarding** to PowerVS Infrastructure.
4. [PowerVS import-workspace variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/import-workspace)
    - Takes information of an existing infrastructure and creates a schematics workspace.
    - The schematics workspace's id and the outputs from it can be used to install the terraform solution 'Power Virtual Server for SAP HANA' on top of a pre-existing PowerVS infrastructure.
    - It creates the ACL and security group rules necessary for management services(NTP. NFS, DNS and proxy server) and schematics engine access.
    - This solution is typically used for converting an existing Power Virtual Server landscape to Schematics workspace.

## Reference architectures
- [PowerVS full-stack variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.md)
- [PowerVS extension variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/extension/deploy-arch-ibm-pvs-inf-extension.md)
- [PowerVS quickstart variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/quickstart/deploy-arch-ibm-pvs-inf-quickstart.md)

## Solutions
| Variation  | Available on IBM Catalog  |  Requires IBM Schematics Workspace ID | Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Full-Stack](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/full-stack)  | :heavy_check_mark:  | N/A  | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |
| [Extension](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/extension)    | :heavy_check_mark:  |  :heavy_check_mark: |  N/A | N/A | :heavy_check_mark:  | N/A | N/A |
| [Quickstart](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/quickstart)    | :heavy_check_mark:  |   N/A  | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | N/A |
| [Import-Workspace](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/import-workspace)    | :heavy_check_mark:  |   N/A  | N/A | N/A | N/A  | N/A | N/A |

<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-powervs-infrastructure](#terraform-ibm-powervs-infrastructure)
* [Submodules](./modules)
    * [ansible-configure-network-services](./modules/ansible-configure-network-services)
    * [powervs-vpc-landing-zone](./modules/powervs-vpc-landing-zone)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

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
        - **Direct Link** service
            - `Editor` platform access

<!-- END MODULE HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
