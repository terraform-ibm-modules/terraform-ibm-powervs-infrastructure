---
copyright:
  years: 2023
lastupdated: "2023-02-21"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: Arnold Beilmann

version: v7.0.0

deployment-url: url #TODO

docs: https://cloud.ibm.com/docs/solution-guide #TODO

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.svg

related_links:
  - title: 'SAP in IBM Cloud documentation'
    url: 'https://cloud.ibm.com/docs/sap'
    description: 'SAP in IBM Cloud documentation.'
  - title: 'Reference architecture for "Secure infrastructure on VPC for regulated industries"'
    url: 'https://url' #TODO
    description: 'Reference architecture for "Secure infrastructure on VPC for regulated industries"'

use-case: ITServiceManagement

industry: Technology

compliance: SAPCertified

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# Power infrastructure for deployable architectures - variation 'PowerVS workspace'
{: #deploy-arch-ibm-pvs-inf-standard}
{: toc-content-type="reference-architecture"}
{: toc-industry="Technology"}
{: toc-use-case="ITServiceManagement"}
{: toc-compliance="SAPCertified"}

'Power Infrastructure for deployable architecture' in variation 'full-stack' creates in one single deployment Power Virtual Server workspace and connects it with VPC services. Proxy service for public internet access from PowerVS workspace is configured.

You can optionally install more management components (such as NFS server, NTP forwarder, and DNS forwarder) on VPC.

## Architecture diagram
{: #architecture-diagram}

![Architecture diagram for 'Power infrastructure for deployable architectures' - variation 'PowerVS workspace'.](deploy-arch-ibm-pvs-inf-full-stack.svg "Architecture diagram"){: caption="Figure 1. Single-zone PowerVS workspace accessible over secure landing zone" caption-side="bottom"}

## Design requirements
{: #design-requirements}

![Design requirements for 'Power infrastructure for deployable architectures' - variation 'PowerVS workspace'.](heat-map-deploy-arch-ibm-pvs-inf-full-stack.svg "Design requirements"){: caption="Figure 2. Scope of the solution requirements" caption-side="bottom"}

IBM Cloud® Power Virtual Servers (PowerVS) is a public cloud offering that an enterprise can use to establish its own private IBM Power computing environment on shared public cloud infrastructure. PowerVS is logically isolated from all other public cloud tenants and infrastructure components, creating a private, secure place on the public cloud. This reference architecture provides a framework to build a PowerVS offering according to the best practices and requirements from the IBM Cloud® deployable architectures framework.

## Components
{: #components}

### VPC architecture decisions
{: #vpc-components-arch}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Ensure public internet connectivity  \n * Isolate most virtual instances to not be reachable directly from the public internet|Edge VPC service|Create a separate VPC service where public internet connectivity is allowed to be configured| |
|* Provide infrastructure administration access  \n * Limit the number of infrastructure administration entry points to ensure security audit|Management VPC service|Create a separate VPC service where SSH connectivity from outside is allowed| |
|* Provide infrastructure for service management components like backup, monitoring, IT service management, shared storage  \n * Ensure you can reach all IBM Cloud and on-premises services|Workload VPC service|Create a separate VPC service as an isolated environment, without direct public internet connectivity and without direct SSH access| |
|* Allow customer to choose operating system from two most widely used commercial Linux operating system offerings  \n * Support new OS releases|Linux operating system|Red Hat Enterprise Linux (RHEL)|SUSE Linux Enterprise Server(SLES)|
|* Create a virtual server instance that can act as an internet proxy server|Proxy server VPC instance|Create a Linux VPC instance that can act as a proxy server. Preconfigure ACL and security group rules to allow public internet traffic over proxy using default proxy ports (3828)|Configure application load balancer to act as proxy server manually|
|* Create a virtual server instance as the only management access point to the landscape|Bastion host VPC instance|Create a Linux VPC instance that acts as a bastion host. Configure ACL and security group rules to allow SSH connectivity (port 22). Add a public IP address to the VPC instance. Allow connectivity from a restricted and limited number of public IP addresses. Allow connectivity from IP addresses of the Schematics engine nodes||
|* Create a virtual server instance to host basic management services like DNS, NTP, NFS|Management services VPC instance|Create a Linux VPC instance that can host management components. Configure ACL and security group rules to allow communication for basic management components.|Modify number of virtual server instances and allowed ports in preset or perform the modifications manually|
|* Ensure financial services compliancy for VPC services  \n * Perform network setup of all created services  \n * Perform network isolation of all created services  \n * Ensure all created services are interconnected |Secure landing zone components|Create a minimum set of required components for a secure landing zone|Create a modified set of required components for a secure landing zone in preset|
{: caption="Table 1. VPC architecture decisions" caption-side="bottom"}

### PowerVS workspace architecture decisions
{: #pvs-components-workspace}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Connect PowerVS workspace with VPC services|Cloud connections|Set up two redundant cloud connections| |
|* Configure the network for management of all instances  \n * Throughput and latency are not relevant|Management network|Configure private network with default configurations and attach it to both cloud connections| |
|* Configure separate network for backup purposes with higher data throughput|Backup network|Configure separate private network with default configurations and attach it to both cloud connections. Networks characteristics might be adapted by the users manually (for example to improve throughput)| |
|* Pre-load OS images relevant for customer workload|Pre-loaded OS images|Pre-load Linux OS images for SAP workload. Keep the number of pre-loaded images at minimum to save costs.|Modify the input parameter that specifies the list of pre-loaded OS images.|
|* Pre-load a public SSH key that will be injected into every OS deployment|Pre-loaded SSH public key|Pre-load customer specified SSH public key| |
{: caption="Table 2. PowerVS workspace architecture decisions" caption-side="bottom"}

### PowerVS management services architecture decisions
{: #pvs-components-mgmt}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Ensure public internet connectivity from all the instances to be deployed in PowerVS workspace|SQUID proxy|Setup SQUID proxy software on Linux virtual server instance running in edge VPC|                    |
|* Provide shared NFS storage that might be directly attached to all the instances to be deployed in PowerVS workspace|NFS server|Export NFS disk attached to Linux virtual server instance running in workload VPC. Disk size is specified by the user.|Shared NFS storage on VPC is optional.|
|* Provide time synchronization to all instances to be deployed in PowerVS workspace|NTP forwarder|Synchronize time using public NTP servers. Setup time synchronization on Linux virtual server instance running in workload VPC.|By using time synchronization servers directly reachable from PowerVS workspace, NTP forwarder is not required.|
|* Provide a DNS forwarder to a DNS server not directly reachable from PowerVS workspace (e.g., running on-premise or in other isolated environment)|DNS forwarder|Configure DNS forwarder on Linux virtual server instance running in workload VPC| By using native IBM Cloud DNS service, DNS forwarder is not needed. Direct domain name resolution is possible.|
{: caption="Table 3. PowerVS management services architecture decisions" caption-side="bottom"}

### Network security architecture decisions
{: #net-sec}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Isolate edge VPC and allow only a limited number of network connections  \n * All other connections from/to edge VPC are forbidden|ACL and security group rules in edge VPC|Open following ports by default: 53 (DNS service), 8443 (OS registration), 443 (HTTPS), 80 (HTTP).  \n All ports to PowerVS workspace are open.  \n All ports to other VPCs are open.|Additional ports might be opened in preset or added manually after deployment|
|* Isolate management VPC and allow only a limited number of network connections  \n * All other connections from/to management VPC are forbidden|ACL and security group rules in management VPC|Open following ports by default: 22 (for limited number of IPs).  \n All ports to PowerVS workspace are open.  \n All ports to other VPCs are open.|Additional ports might be opened in preset or added manually after deployment|
|* Isolate workload VPC and allow only a limited number of network connections  \n * All other connections from/to workload VPC are forbidden|ACL and security group rules in workload VPC|Open following ports by default: 53 (DNS service).  \n All ports to PowerVS workspace are open.  \n All ports to other VPCs are open.|Additional ports might be opened in preset or added manually after deployment|
|* Enable floating IP on bastion host to execute deployment|Floating IPs on bastion host in management VPC|Use floating IP on bastion host from IBM Schematics to complete deployment|                    |
|* Pre-load VPN configuration to simplify VPN setup|VPNs|VPN configuration is the responsibility of the customer|                    |
{: caption="Table 4. Network security architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #key-pw}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Use public/private SSH key to access virtual server instances via SSH  \n * Use SSH proxy to login on all virtual server instances via the bastion host  \n * Do not store private ssh key on any virtual instances, also not on the bastion host  \n * Do not allow any other SSH login methods except the one with specified private/public SSH key pair|Public SSH key - provided by customer. Private SSH key - provided by customer.|Ask customer to specify the keys. Accept the input as secure parameter or as reference to the key stored in IBM Cloud Secure Storage Manager. Do not print SSH keys in any log files. Do not persist private SSH key.|                    |
{: caption="Table 5. Key and passwords management architecture decisions" caption-side="bottom"}

## Compliance
{: #compliance}

This reference architecture is certified for SAP deployments.

## Next steps
{: #next-steps}

Install the SAP on Power deployable architecture on this infrastructure.