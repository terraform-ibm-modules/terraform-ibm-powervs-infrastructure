# IBM Power Virtual Server with VPC Landing Zone

[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-infrastructure?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

## Summary
This repository contains deployable architecture solutions that help provision VPC landing zones, PowerVS workspaces, and interconnect them. The solutions are available in the IBM Cloud Catalog and can also be deployed without the catalog, except for the second solution below.

Three solutions are offered:
1. [Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard)
    - Creates a VPC and Power Virtual Server workspace, interconnects them, and configures OS network management services (SQUID proxy, NTP, NFS, and DNS services) using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
2. [Quickstart (Standard Landscape plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-plus-vsi)
    - Creates a VPC and a Power Virtual Server workspace, interconnects them, and configures operating network management services (SQUID proxy, NTP, NFS, and DNS services) using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
    - Additionally creates a Power Virtual Server Instance of a selected t-shirt size. Network management services, filesystems and SCC Workload protection agents are configured for AIX and Linux instances.
    - This solution is typically utilized for **PoCs, demos, and quick onboarding** to PowerVS Infrastructure.
3. [Quickstart OpenShift](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-openshift)
    - Creates a VPC and a Power Virtual Server workspace and then deploys an OpenShift Cluster in them by using the [RedHat IPI Installer](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/installing_on_ibm_power_virtual_server/index) for IBM PowerVS.
    - The number of PowerVS Master and Worker nodes and their compute configuration is fully customizable.
    - Optionally creates IBM Cloud Monitoring and a SCC Workload protection instances.
    - This solution is typically utilized for **PoCs, demos, and quick onboarding** of OpenShift on PowerVS Infrastructure.

## Reference architectures
- [Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/standard/deploy-arch-ibm-pvs-inf-standard.md)
- [Quickstart (Standard Landscape plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/standard-plus-vsi/deploy-arch-ibm-pvs-inf-standard-plus-vsi.md)
- [Quickstart OpenShift](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/reference-architectures/standard-openshift/deploy-arch-ibm-pvs-inf-standard-openshift.md)

## Solutions

| Variation  | Available on IBM Catalog  |   Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Standard Landscape](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard)  | :heavy_check_mark:   | :heavy_check_mark:  | :heavy_check_mark:  |  :heavy_check_mark: | N/A | N/A |
| [Quickstart (Standard Landscape plus VSI)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-plus-vsi)    | :heavy_check_mark:    | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |
| [Quickstart OpenShift](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/solutions/standard-openshift)    | :heavy_check_mark:    | :heavy_check_mark:| :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |


## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **All Account Management services** service
        - `Administrator` platform access
    - IAM Services
        - **IAM Identity Service** service
            - `Administrator` platform access
        - **All Identity and Access enabled services** service
            -`Manager` service access
            -`Administrator` platform access
    - Resource Management
        - **Resource Management** service
            -`Administrator` platform access
    - Networking Services
        - **VPC Infrastructure Services** service
            -`manager` service access
            -`VPN Client` , `Administrator` ,`Share Broker` , `Share Remote Account Accessor` platform access
        - **Transit Gateway** service
            -`manager` service access
            -`Editor` platform access
    - Compute Services
        - **Power Virtual Server Workspace** service
            -`Manager` service access
            -`Editor` platform access
    - Security Services
        - **Key Protect** service
            -`Manager` service access
            -`Administrator` platform access
        - **Secrets Manager** service
            -`Manager` service access
            -`Administrator` platform access
        - **Hyper Protect Crypto Services** service
            -`Manager` service access
            -`Administrator` platform access
        - **Security and Compliance Center Workload Protection** service
            -`Manager` service access
            -`Administrator` platform access
    - Monitoring & Management
        - **Cloud Monitoring** service
            -`Manager` service access
            -`Administrator` platform access
        - **Monitoring** service
            -`Administrator` platform access
        - **Activity Tracker Event Routing** service
            -`Editor` platform access
    - Storage Services
        - **Cloud Object Storage** service
            -`Manager` service access
            -`Administrator` platform access
        - **Container Registry** service
            -`Reader` service access
            -`Viewer` platform access
    - Application Services
        - **App Configuration service** service
            -`Manager` service access
            -`Administrator` platform access

<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repository. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
