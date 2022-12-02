#!/bin/bash

test_locations=$1

yes N | ibmcloud login --apikey "$API_KEY" -r "us-south"
#locations=($test_locations)
IFS=" " read -r -a locations <<< "$test_locations"
testable_locs_string=""
for i in "${!locations[@]}"; do
    pvs_zone=${locations[$i]}
    slz_region=$(awk -v key="$pvs_zone" -F',' '{ if ($1 == key) { print $2 } }' test-assets/documents/slz_locations.csv)

    if ibmcloud schematics workspace list | grep "auto-test-$slz_region"; then
        echo "Test skipped for $pvs_zone: SLZ already existing for $slz_region"
        continue
    fi

    if ibmcloud resource service-instances -g Automation | grep "at-$pvs_zone-$pvs_zone"; then
        echo "Test skipped for $pvs_zone: Power Worspace already existing for zone $pvs_zone"
        continue
    fi

    if ibmcloud dl gws | grep "$pvs_zone"; then
        echo "Test skipped for $pvs_zone: Direct Link Connect/Cloud Connections already existing in location $pvs_zone"
        continue
    fi

    if [ "$testable_locs_string" != "" ];then
        testable_locs_string=$testable_locs_string","$pvs_zone
    else
        testable_locs_string=$pvs_zone
    fi
done

testable_locs_string="\"${testable_locs_string//,/\",\"}\""
echo "$testable_locs_string"
#echo "TESTABLE_LOCATIONS=${TESTABLE_LOCATIONS}" >> testlocations.env
