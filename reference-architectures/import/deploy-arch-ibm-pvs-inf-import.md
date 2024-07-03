---
copyright:
  years: 2024
lastupdated: "2024-07-02"
keywords:
subcollection: deployable-reference-architectures
authors:
  - name: Arnold Beilmann
  - name: Stafania Saju
production: true
deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global
docs: https://cloud.ibm.com/docs/powervs-vpc
image_source: https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/reference-architectures/import/deploy-arch-ibm-pvs-inf-import.svg
use-case: ITServiceManagement
industry: Technology
compliance:
content-type: reference-architecture
version: v5.2.1

---

{{site.data.keyword.attribute-definition-list}}

# Power Virtual Server with VPC landing zone - as 'Import' deployment
{: toc-content-type="reference-architecture"}
{: toc-industry="Technology"}
{: toc-use-case="ITServiceManagement"}
{: toc-compliance="SAPCertified"}
{: toc-version="5.2.1"}

This solution helps to install the deployable architecture ['Power Virtual Server for SAP HANA'](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global) on top of a pre-existing Power Virtual Server(PowerVS) landscape. 'Power Virtual Server for SAP HANA' automation requires a schematics workspace id for installation. The 'Import' solution creates a schematics workspace by taking pre-existing VPC and PowerVS infrastructure resource details as inputs. The ID of this schematics workspace will be the pre-requisite workspace id required by 'Power Virtual Server for SAP HANA' to create and configure the PowerVS instances for SAP on top of the existing infrastructure.

## Architecture diagram
{: #iw-architecture-diagram}

![Architecture diagram for 'Power Virtual Server with VPC landing zone' - variation 'Import'.](deploy-arch-ibm-pvs-inf-import.svg "Architecture diagram"){: caption="Figure 1. Power Virtual Server with VPC landing zone 'Import' variation" caption-side="bottom"}{: external download="deploy-arch-ibm-pvs-inf-import.svg"}
