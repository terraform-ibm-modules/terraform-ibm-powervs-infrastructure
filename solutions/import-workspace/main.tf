#################################################################################################

# This solution creates a schematics workspace for a pre-existing
# VPC and PowerVS Infrastructure. The schematics workspace id can
# be used to install the deployable architecture automations to
# create and configure the Power LPARs for SAP. Please refer the
# files:
# 1. import_vpc     - Imports the data of user-provided access host(jump host) vsi
#                     in management VPC.
#                   - Creates the necessary ACL rules to allow the schematics engine
#                     servers to acsess the jump host during 'Power Virtual Server for SAP HANA'
#                     automation deployment.
# 2. import_powervs - Imports the data of power virtual server workspace

#################################################################################################
