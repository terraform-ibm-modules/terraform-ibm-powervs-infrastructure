##############################################################################################

# This solution creates a schematics workspace for a pre-existing
# VPC and PowerVS Infrastructure. The schematics workspace id can
# be used to install the deployable architecture automations to
# create and configure the Power LPARs for SAP. Please refer the
# files:
# 1. import_vpc     - imports the data of management, edge and workload vpcs and their VSis
#                     and creates the necessary ACL and security group rules to allow the
#                     schematics engine servers to reach the proxy, NTP, NFS and DNS services
# 2. import_powervs - imports the data of power virtual server workspace

##############################################################################################
