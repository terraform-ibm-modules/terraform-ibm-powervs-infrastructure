#!/bin/bash

# SLZ deployment prep
TEST_LOCATION=$(awk -v key="$PVS_ZONE" -F',' '{ if ($1 == key) { print $2 } }' test-assets/documents/slz_locations.csv)
echo "$TEST_LOCATION"

export PREFIX="at-$PVS_ZONE"
echo "$PREFIX"

tmp=$(mktemp)
jq --arg a "${TEST_LOCATION}" '.region = $a' test-assets/documents/rhelconfig.json > "$tmp" && mv "$tmp" test-assets/documents/rhelconfig.json
jq --arg b "${PREFIX}" '.prefix = $b' test-assets/documents/rhelconfig.json > "$tmp" && mv "$tmp" test-assets/documents/rhelconfig.json

# local testing
#jq --arg a "${TEST_LOCATION}" '.region = $a' documents/rhelconfig.json > "$tmp" && mv "$tmp" documents/rhelconfig.json
#jq --arg b "${PREFIX}" '.prefix = $b' documents/rhelconfig.json > "$tmp" && mv "$tmp" documents/rhelconfig.json

# @Before: Preparation of slz_config file for respective RHEL/SLES case
# jq --arg a "${TEST_LOCATION}" '.region = $a' test-assets/documents/slz_config.json > "$tmp" && mv "$tmp" test-assets/documents/slz_config.json
# jq --arg b "${PREFIX}" '.prefix = $b' test-assets/documents/slz_config.json > "$tmp" && mv "$tmp" test-assets/documents/slz_config.json
# rhel=$(cat documents/rhel_slz_override.json | jq tojson)
# jq --argjson a "$rhel" '.override_json_string = $a' documents/slz_config.json > documents/rhelconfig.json

# SLZ Deployment

# 1. Define SLZ Name
slzName="auto-test-$TEST_LOCATION-$(date +'%d-%m-%Y')"
echo "STEP 1: Define SLZ name"
echo "$slzName"

# 2. IBM Login
echo "STEP 2: IBMCloud Login"
yes N | ibmcloud login --apikey "$API_KEY" -r "us-south"

# 3. Selection of resource group
echo "STEP 3: Selection of resource group"
ibmcloud target -g Default

# 4. SLZ deplyoment from catalog
echo "STEP 4: SLZ Deployment"
ibmcloud catalog install --vl 1082e7d2-5e2f-0a11-a3bc-f88a8e1931fc.1cb52f62-4272-4876-bd9e-e3c02fa684e8-global --override-values test-assets/documents/rhelconfig.json --workspace-name "$slzName"
sleep 600

# 5. Extract the workspace-id of the deployed SLZ
ws_id=$(ibmcloud schematics workspace list | grep "${slzName}" | awk '{print $2}')
echo "STEP 5: EXTRACT Workspace ID"
echo "$ws_id"

# 6. Check the status of the workspace
count=0
while [[ $count -le 6 ]]; do
    sleep 60
    if [[ $(ibmcloud schematics workspace get --id "${ws_id}" --output JSON | grep -w \"status\") =~ "\"ACTIVE\"" ]]; then
        break
    fi
    count=$((count + 1))
done

if [[ $(ibmcloud schematics workspace get --id "${ws_id}" --output JSON | grep -w \"status\") =~ "\"ACTIVE\"" ]]; then
    echo "Installation Successful"
else
    echo "Workspace Status not active"
    exit 1
fi

# 7. Prep for terraform deploy of powervs infra
echo "STEP 7: Preparing input files"
sed -i "s/###apikey###/${API_KEY}/" test-assets/infra-inputs/input.tfvars
sed -i "s/###ws-id###/${ws_id}/" test-assets/infra-inputs/input.tfvars
sed -i "s/###pvs-zone###/${PVS_ZONE}/" test-assets/infra-inputs/input.tfvars

input_loc=$(pwd)/test-assets/infra-inputs/input.tfvars
echo "input file $input_loc"

# 8. Terraform deploy of powervs infra
echo "STEP 8: PVS Infra deployment"
cd examples/ibm-catalog/standard-solution || exit
terraform init

RETVAL=$?
[ ${RETVAL} -eq 0 ] && terraform apply --var-file "$input_loc" -auto-approve || RETVAL=1
return ${RETVAL}

terraform destroy --var-file "$input_loc" -auto-approve

# 9. SLZ Cleanup
echo "Destroying SLZ"
yes y | ibmcloud schematics destroy --id "${ws_id}"
sleep 600

count=0
while [[ $count -le 6 ]]; do
    sleep 60
    if [[ $(ibmcloud schematics workspace get --id "${ws_id}" --output JSON | grep -w \"status\") =~ "INACTIVE" ]]; then
        echo "SLZ is INACTIVE"
        yes y | ibmcloud schematics workspace delete --id "${ws_id}"
        break
    fi
    count=$((count + 1))
done

# IBMCloud logout
echo "FINAL STEP: IBMCloud Logout"
ibmcloud logout
