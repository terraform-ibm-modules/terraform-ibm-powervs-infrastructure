---

# The YAML header is required. For more information about the YAML header, see
# https://test.cloud.ibm.com/docs/writing?topic=writing-reference-architectures

copyright:
  years: 2023
lastupdated: "2023-02-21"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: Arnold Beilmann

# The release that the reference architecture describes
version: v7.0.0

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: url #TODO

docs: https://cloud.ibm.com/docs/solution-guide #TODO

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/reference-architectures/standard/deploy-arch-ibm-pvs-inf-standard.svg

related_links:
  - title: 'SAP in IBM Cloud documentation'
    url: 'https://cloud.ibm.com/docs/sap'
    description: 'SAP in IBM Cloud documentation.'
  - title: 'Reference architecture for "Secure infrastructure on VPC for regulated industries"'
    url: 'https://url' #TODO
    description: 'Reference architecture for "Secure infrastructure on VPC for regulated industries"'

# use-case from 'code' column in
# https://github.ibm.com/digital/taxonomy/blob/main/subsets/use_cases/use_cases_flat_list.csv
use-case: ITServiceManagement

# industry from 'code' column in
# https://github.ibm.com/digital/taxonomy/blob/main/industries/industry_sectors%20-%20flat%20list.csv
industry: Technology

# compliance from 'code' column in
# https://github.ibm.com/digital/taxonomy/blob/main/compliance_entities/compliance_entities_flat_list.csv
compliance: SAPCertified

content-type: reference-architecture

---

<!--
The following line inserts all the attribute definitions. Don't delete.
-->
{{site.data.keyword.attribute-definition-list}}

<!--
Don't include "reference architecture" in the following title.
Specify a title based on a use case. If the architecture has a module
or tile in the IBM Cloud catalog, match the title to the catalog. See
https://test.cloud.ibm.com/docs/solution-as-code?topic=solution-as-code-naming-guidance.
-->

# Power infrastructure for deployable architectures - variation 'PowerVS workspace'
{: #deploy-arch-ibm-pvs-inf-standard}
{: toc-content-type="reference-architecture"}
{: toc-industry="value"}
{: toc-use-case="ITServiceManagement"}
{: toc-compliance="SAPCertified"}

<!--
The IDs, such as {: #title-id} are required for publishing this reference architecture in IBM Cloud Docs. Set unique IDs for each heading. Also include
the toc attributes on the H1, repeating the values from the YAML header.
 -->

Building upon the VPC service that were previously created when you deployed Secure infrastructure on VPC for regulated industries, Power Infrastructure for deployable architectures creates a Power Virtual Server workspace and connects it with VPC services. Proxy service for public internet access from PowerVS workspace is configured.

Additional management components (NFS server, NTP forwarder, and DNS forwarder) may be installed on VPC optionally.

## Architecture diagram
{: #architecture-diagram}

![Architecture diagram for 'Power infrastructure for deployable architectures' - variation 'PowerVS workspace'.](deploy-arch-ibm-pvs-inf-standard.svg "Architecture diagram"){: caption="Figure 1. Single-zone PowerVS workspace accessable over secure landing zone" caption-side="bottom"}

## Design requirements
{: #design-requirements}

![Design requirements for 'Power infrastructure for deployable architectures' - variation 'PowerVS workspace'.](heatmap.svg "Design requirements"){: caption="Figure 1. Scope of the solution requirements" caption-side="bottom"}

IBM Cloud® Power Virtual Servers (PowerVS) is a public cloud offering that lets an enterprise establish its own private IBM Power computing environment on shared public cloud infrastructure. PowerVS is logically isolated from all other public cloud tenants and infrastrucutre components, creating a private, secure place on the public cloud. The reference architecture for 'Power infrastructure for deployable architectures' - variation 'PowerVS workspace' is designed to provide a framework for building a PowerVS offering according to the best practices and requirements using IBM Cloud® deployable architectures framework.

## Components
{: #components}

### VPC architecture decisions
{: #vpc-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|
* ensure public internet connectivity
* most of virtual instances must be isolated and not be reachable directly from public internet

|
Edge VPC service
|
Create a separate VPC service where public internet connectivity is allowed to be configured
||

|
* provide infrastructure administration access
* number of infrastructure administration entry points should be limited in order to ensure security audit

|
Management VPC service
|
Create a separate VPC service where SSH connectivity from outside is allowed
||

|
* provide infrastructure for service management componets like backup, monitoring, IT service management, shared storage
* ensure you can reach all IBM Cloud and on-premise services

|
Workload VPC service
|
Create a separate VPC service as an isolated environment, without direct public internet connectivity and without direct SSH access
||

|
* create virtual server instance that may act as internet proxy server

|
Proxy server VPC instance
|
Create Linux VPC instance that may act as proxy server. Preconfigure ACL and security group rules to allow public internet traffic over proxy using default proxy ports (3828).
|
Configure application loadbalancer to act as proxy server manually.
|

|
* create virtual server instance as only management access point to the landscape

|
Bastion host VPC instance
|
Create Linux VPC instance that acts as bastion host. Preconfigure ACL and security group rules to allow SSH connectivity (port 22). Add public IP address to the VPC instance. Allow connectivity from a restricted and limited number of public IP addresses. Allow connectivity from IP addresses of the Schematics engine nodes
||

|
* create virtual server instance to host basic management services like DNS, NTP, NFS

|
Management services VPC instance
|
CreateLinux VPC instance that may host management components. Preconfigure ACL and security group rules to allow communication for basic management componets (NFS - ports XXX, NTP - ports XXX, DNS - ports XXX)
|
Modify number of virtual server instances and allowed ports in preset or perform the modifications manually
|

|
* ensure financial services compliancy for VPC services
* perform network setup of all created services
* perform network isolation of all created services
* ensure all created services are inteconnected with each other

|
Secure landing zone components
|
Create a minimum set of required components for a secure landing zone
|
Create a modified set of required components for a secure landing zone in preset
|
{: caption="Table 1. VPC architecture decisions" caption-side="bottom"}

### PowerVS workspace architecture decisions
{: #pvs-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* connect PowerVS workspace with VPC services|Cloud connections|Setup two redundant cloud connections|                    |
|-------------|-----------|--------------------|--------------------|
|* configure network for management of all the instances|Management network|Configure private network with default configurations and attch it to both cloud connections|                    |
|* troughput and latency are not relevant| | | |
|-------------|-----------|--------------------|--------------------|
|* configure separate network for backup purposes with higher data throughput|Backup network|Configure separate private network with default configurations and attch it to both cloud connections. Networks characteristics might be adapted by the users manually (e.g., to improve throughput)|                    |
|-------------|-----------|--------------------|--------------------|
|* preload OS images relevant for customer workload|Pre-loaded OS images|Preload Linux OS images for SAP workload. Keep the number of preloaded images at minimum to save corsts.|Modify the input parameter that specify the list of preloaded OS images.|
|-------------|-----------|--------------------|--------------------|
|* preload public SSH key that will be injected into every OS deployment|Pre-loaded SSH public key|Preload customer specified SSH public key|                    |
{: caption="Table 2. PowerVS workspace architecture decisions" caption-side="bottom"}

### PowerVS management services architecture decisions
{: #vpc-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* ensure public internet connectivity from all the instances to be deployed in PowerVS workspace|SQUID proxy|Setup SQUID proxy software on Linux virtual server instance runnning in edge VPC|                    |
|-------------|-----------|--------------------|--------------------|
|* provide shared NFS storage that might be directly attached to all the instances to be deployed in PowerVS workspace|NFS server|Export NFS disk attached to Linux virtual server instance runnning in workload VPC. Disk size is specified by the user.|Shared NFS storage on VPC is optional.|
|-------------|-----------|--------------------|--------------------|
|* provide time synchronisation to all instances to be deployed in PowerVS workspace|NTP forwarder|Sinchronize time using public NTP servers. Setup time sinchronisation on Linux virtual server instance runnning in workload VPC.|By using time sinchronisation servers directly reachable from PowerVS workspace, NTP forwarder is not required.|
|-------------|-----------|--------------------|--------------------|
|* provide a DNS forwarder to a DNS server not directly reachable from PowerVS workspace (e.g., running on-premise or in other isolated environment)|DNS forwarder|Configure DNS forwarder on Linux virtual server instance runnning in workload VPC| By using native IBM Cloud DNS service, DNS forwarder is not needed. Direct domain name resolution is possible.|
{: caption="Table 3. PowerVS management services architecture decisions" caption-side="bottom"}

### Network security architecture decisions
{: #vpc-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* isolate edge VPC and allow only a limited number of network connections|ACL and security group rules in edge VPC|Open following ports by default:|Additional ports might be opened in preset or added manually after deployment|
|* all other connections from/to edge VPC are forbidden| | | |
|-------------|-----------|--------------------|--------------------|
|* isolate management VPC and allow only a limited number of network connections|ACL and security group rules in management VPC|Open following ports by default:|Additional ports might be opened in preset or added manually after deployment|
|* all other connections from/to edge VPC are forbidden| | | |
|-------------|-----------|--------------------|--------------------|
|* isolate workload VPC and allow only a limited number of network connections|ACL and security group rules in workload VPC|Open following ports by default:|Additional ports might be opened in preset or added manually after deployment|
|* all other connections from/to workload VPC are forbidden| | | |
|-------------|-----------|--------------------|--------------------|
|* enable floating IP on bastion host to execute deployment|Floating IPs on bastion host in management VPC|Use floating IP on bastion host from IBM Schematics to complete deployment|                    |
|-------------|-----------|--------------------|--------------------|
|* preload VPN configuration to simplify VPN setup|VPNs|VPN configuration is the responsibility of the customer|                    |
{: caption="Table 4. Network security architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #vpc-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* use public/private SSH key to access virtual server instances via SSH|public SSH key - provided by customer. private SSH key - provided by customer.|As customer to specify the keys. Accept the input as secure parameter or as reference in IBM Cloud Secure Storage Manager. Do not print SSH keys in any log files. Do not persist private SSH key.|                    |
|* use SSH proxy to login on all virtual server instances via the bastion host| | | |
|* do not store private ssh key on any virtual instances, also not on the bastion host| | | |
|* do not keep any SSH login posibilities other than specified private/public SSH key pair| | | |
{: caption="Table 4. Key and passwords management architecture decisions" caption-side="bottom"}

## Compliance
{: #compliance}

This reference architecture is certified for SAP deployments.

## Next steps
{: #next-steps}

As next step, you install deployable architecture 'SAP on Power' on top of that infrastructure.
