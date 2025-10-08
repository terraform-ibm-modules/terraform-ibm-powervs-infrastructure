---
copyright:
  years: 2024, 2025
lastupdated: "2025-10-08"
keywords:
subcollection: deployable-reference-architectures
authors:
  - name: Arnold Beilmann
  - name: Suraj Bharadwaj
  - name: Ludwig Mueller
production: true
deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global
docs: https://cloud.ibm.com/docs/powervs-vpc
image_source: https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-openshift/deploy-arch-ibm-pvs-inf-standard-openshift.svg
use-case: ITServiceManagement
industry: Technology
content-type: reference-architecture
version: v10.0.1
compliance:

---

{{site.data.keyword.attribute-definition-list}}

# Power Virtual Server with VPC landing zone - 'Quickstart Openshift Variation'
{: #deploy-arch-ibm-pvs-inf-standard-openshift}
{: toc-content-type="reference-architecture"}
{: toc-industry="Technology"}
{: toc-use-case="ITServiceManagement"}
{: toc-version="v10.0.1"}

The Quickstart OpenShift deployment on Power Virtual Server with a VPC landing zone uses the Red Hat IPI installer to set up an OpenShift cluster. Before the deployment begins, it provisions VPC services and creates a Power Virtual Server workspace, which together form the landing zone used to access and manage the cluster.

The number of PowerVS master and worker nodes and their respective compute configurations can be configured during deployment. Optionally, Monitoring and Security and Compliance Center Workload Protection can also be configured.

## Architecture diagram
{: #standard-openshift-architecture-diagram}

![Architecture diagram for 'Power Virtual Server with VPC landing zone' - variation 'Quickstart Openshift'.](deploy-arch-ibm-pvs-inf-standard-openshift.svg "Architecture diagram"){: caption="Figure 1. Single-zone PowerVS workspace accessible over secure landing zone" caption-side="bottom"}{: external download="deploy-arch-ibm-pvs-inf-standard-openshift.svg"}

## Design requirements
{: #standard-openshift-design-requirements}

![Design requirements for 'Power Virtual Server with VPC landing zone' - variation 'Quickstart'](heat-map-deploy-arch-ibm-pvs-inf-standard-openshift.svg "Design requirements"){: caption="Figure 2. Scope of the solution requirements" caption-side="bottom"}

IBM Cloud® Power Virtual Servers (PowerVS) is a public cloud offering that an enterprise can use to establish its own private IBM Power computing environment on shared public cloud infrastructure. PowerVS is logically isolated from all other public cloud tenants and infrastructure components, creating a private, secure place on the public cloud. This deployable architecture provides a framework to build a PowerVS offering according to the best practices and requirements from the IBM Cloud.

## Landing Zone Components
{: #standard-openshift-landing-zone-components}

### VPC architecture decisions
{: #standard-openshift-vpc-components-arch}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Ensure public internet connectivity  \n * Isolate most virtual instances to not be reachable directly from the public internet|Edge VPC service with network services security group.|Create a separate security group service where public internet connectivity is allowed to be configured| |
|* Provide infrastructure administration access  \n * Limit the number of infrastructure administration entry points to ensure security audit|Edge VPC service with management security group.|Create a separate security group where SSH connectivity from outside is allowed| |
|* Provide infrastructure for service management components like backup, monitoring, IT service management, shared storage  \n * Ensure you can reach all IBM Cloud and on-premises services|Client to site VPN and security groups |Create a client to site VPN and VPE full strict security groups rules without direct public internet connectivity and without direct SSH access| |
|* Allow customer to choose operating system from two most widely used commercial Linux operating system offerings  \n * Support new OS releases|Linux operating system|Red Hat Enterprise Linux (RHEL)| |
|* Create a virtual server instance as the only management access point to the landscape|Bastion host VPC instance|Create a Linux VPC instance that acts as a bastion host. Configure ACL and security group rules to allow SSH connectivity (port 22). Add a public IP address to the VPC instance. Allow connectivity from a restricted and limited number of public IP addresses. Allow connectivity from IP addresses of the Schematics engine nodes| |
|* Create a virtual server instance that can act as an internet proxy server |Network services VPC instance|Create a Linux VPC instance that can host management components. Preconfigure ACL and security group rules to allow traffic over private networks only.|Configure application load balancer to act as proxy server manually, Modify number of virtual server instances and allowed ports in preset or perform the modifications manually|
|* Create DNS Service instance as pre-requisite for IPI installer | DNS Service Instance | Create a DNS Service instance and a custom resolver to internally resolve the cluster domain. | |
|* Ensure financial services compliancy for VPC services  \n * Perform network setup of all created services  \n * Perform network isolation of all created services  \n * Ensure all created services are interconnected |Secure landing zone components|Create a minimum set of required components for a secure landing zone|Create a modified set of required components for a secure landing zone in preset|
|* Allow customer to optionally enable monitoring in the deployment|IBM Cloud® monitoring instance and Monitoring Host VPC Instance|Optionally, create or import an existing IBM Cloud® monitoring instance (customer provided details) and create and pre-configure the Monitoring Host VPC instance to  collect information and send it to the IBM Cloud® monitoring instance.| |
|* Allow customer to optionally enable [Security and Compliance Center Workload Protection](/docs/workload-protection) in the deployment \n * Collect posture management information, enable vulnerability scanning and threat detection|IBM Cloud® Security and Compliance Center Workload Protection and SCC Workload Protection agent on all VPC instances in the deployment.|Optionally, create an IBM Cloud® Security and Compliance Center Workload Protection instance and install and setup the SCC Workload Protection agent on all VPC instances in the deployment (bastion, network services, monitoring hosts).| |
{: caption="Table 1. VPC architecture decisions" caption-side="bottom"}

### PowerVS workspace architecture decisions
{: #standard-openshift-pvs-components-workspace}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Connect PowerVS workspace with VPC services|Transit gateway| Set up a local transit gateway| |
|* Preload a public SSH key that is injected into every OS deployment|Preloaded SSH public key|Preload customer specified SSH public key| |
{: caption="Table 2. PowerVS workspace architecture decisions" caption-side="bottom"}

### Network security architecture decisions
{: #standard-openshift-net-sec}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Preload VPN configuration to simplify VPN setup|VPNs|VPN configuration is the responsibility of the customer. Automation creates a client to site VPN server| |
|* Enable floating IP on bastion host to execute deployment|Floating IPs on bastion host in management VPC|Use floating IP on bastion host from IBM Schematics to complete deployment| |
|* Isolate management VSI and allow only a limited number of network connections  \n * All other connections from or to management VPC are forbidden|Security group rules for management VSI|Open following ports by default: 22 (for limited number of IPs).  \n All ports to PowerVS workspace are open.  \n All ports to other VPCs are open.|More ports might be opened in preset or added manually after deployment|
|* Isolate network services VSI and VPEs |Security group rules in edge VPC|Separate security groups are created for each component and only certain IPs or Ports are allowed. |More ports might be opened in preset or added manually after deployment|
{: caption="Table 3. Network security architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #standard-openshift-key-pw}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Use public/private SSH key to access virtual server instances by using SSH  \n * Use SSH proxy to log in to all virtual server instances by using the bastion host  \n * Do not store private ssh key on any virtual instances, also not on the bastion host  \n * Do not allow any other SSH login methods except the one with specified private/public SSH key pair|Public SSH key - provided by customer. Private SSH key - provided by customer.|Ask customer to specify the keys. Accept the input as secure parameter or as reference to the key stored in IBM Cloud Secure Storage Manager. Do not print SSH keys in any log files. Do not persist private SSH key.|                    |
|* Use public/private SSH key to access virtual server instances by using SSH  \n * Use SSH proxy to log in to all virtual server instances by using the private IPS of instances using a VPN client  \n * Do not store private ssh key on any virtual instances  \n * Do not allow any other SSH login methods except the one with specified private/public SSH key pair|Public SSH key - provided by customer. Private SSH key - provided by customer.|Ask customer to specify the keys. Accept the input as secure parameter or as reference to the key stored in IBM Cloud Secure Storage Manager. Do not print SSH keys in any log files. Do not persist private SSH key.|                    |
{: caption="Table 5. Key and passwords management architecture decisions" caption-side="bottom"}

## OpenShift Components
{: #standard-openshift-openshift-components}

Once the landing zone components are deployed, this architecture leverages the [RedHat IPI installer](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/installing_on_ibm_power_virtual_server/index){: external} to create an OpenShift cluster.

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------|--------------------|
|* Deploy PowerVS instances for Bootstrap (temporary), Master, and Worker nodes. | PowerVS instances | The customer can specify the number of master and worker nodes and customize their compute profiles. |
|* Modify the DNS Service instance to correctly resolve the cluster API | DNS Service instance | Add CNAME entries to DNS zone to resolve internal and external cluster APIs. Only support .test, .example, .invalid domains to prevent public resolution. |
|* Application Load Balancers to establish connectivity to the cluster API. | Three Application Load Balancers | One for internal API, one for external api, and one for the applications deployed in the cluster. |
|* Use DHCP to dynamically assign IP addresses to the nodes | DHCP Subnet in PowerVS | Machine network dynamically assigns IP addresses to the nodes. |
|* Modify security groups to allow network traffic to API. | Default Security Group | The default security group is attached to the load balancers and configured so the required network traffic is able to pass. |
{: caption="Table 6. OpenShift architecture decisions" caption-side="bottom"}
