# IBM Cloud solution for Power Virtual Server with VPC landing zone Import-Workspace Variation

This solution helps to install the deployable architecture ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) on top of a pre-existing Power Virtual Server(PowerVS) landscape. 'Power Virtual Server for SAP HANA' automation requires a schematics workspace id for installation. The 'import-workspace' solution creates a schematics workspace by taking pre-existing VPC and PowerVS infrastructure resource details as inputs. The ID of this schematics workspace will be the pre-requisite workspace id required by 'Power Virtual Server for SAP HANA' to create and configure the PowerVS instances for SAP on top of the existing infrastructure.

### Pre-requisites:
The pre-existing infrastructure must meet the following conditions to use the 'import-workspace' solution to create a schematics workspace:
- **Virtual Private Cloud(VPC) side**
    - Existing VPC or VPCs with virtual servers instances, ACL/ACLs, and Security Groups.
    - Existing access host(jump server) which is an intel based virtual server instance that can access Power virtual server instances.
    - Existing Transit Gateway.
    - The VPC in which the jump host exists must be attached to the Transit Gateway.
    - The necessary ACLs and security group rules for VPC in which the access host(jump server) exists must allow SSH login to the Power virtual server instances which would be created using ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) automation.
- **Power Virtual Server Workspace side**
    - Existing Power Virtual Server Workspace with at-least two private subnets.
    - Power Virtual Server Workspace/Cloud Connections must be attached to above Transit Gateway.
    - SSH key pairs used to login to access host/jump host(intel based virtual server instance) on VPC side should match to the existing SSH key used in PowerVS Workspace.
- **Mandatory Management Network Services**
    - Existing Proxy server ip and port required to configure the internet access required for PowerVS instances.
- **Optional Management Network Services**
    - Existing DNS server ip for the PowerVS instances.
    - Existing NTP server ip for the PowerVS instances.
    - Existing NFS server ip and path for the PowerVS instances.
    - If the above parameters are provided, then it must be made sure IPs are reachable on Power virtual server instances which would be created using ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) automation.

NOTE: IBM Cloud has a quota of 100 ACL rules per ACL. The 'Import-Workspace' variation will create 52 new ACL rules for providing schematics servers access to the access host(this access is required for 'Power Virtual Server for SAP HANA' automation). Please ensure the concerned ACL can take in new ACL rules without exceeding the quota of 100 so the deployment will be successful.

#### Resources Created:
1. ACL rules for IBM Cloud Schematics are created for the VPC subnets in which access host(jump server) exists.
2. Schematics workspace required by 'Power Virtual Server for SAP HANA' to create and configure the PowerVS instances for SAP on top of the existing infrastructure.

### Notes:

| Variation  | Available on IBM Catalog  |  Requires Schematics Workspace ID | Imports VPC Landing Zone | Imports VPC VSI OS Config | Imports PowerVS Infrastructure | Imports PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [Import-Workspace](./)  | :heavy_check_mark:  | N/A  | N/A  | N/A  |  N/A  | N/A | N/A |

## Architecture diagram
![import-workspace-variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/import-workspace/deploy-arch-ibm-pvs-inf-import-workspace.svg)
