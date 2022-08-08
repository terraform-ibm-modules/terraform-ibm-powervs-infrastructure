// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "examples/default"
const prefix = "work"
const workspace_id = ""
const pvs_zone = "sao01"
const pvs_resource_group_name = "Automation"
const ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZdQYXrRuCOES9/7DhBZ5BHG5/y6/x8algnv8vbg07pM7r+DtIQ6ZekVFuDzsq+76TurwQRW1hypRqjtPzUYeJMRPJUILHWl6CwXo6ihxUzmBBmdxp1bIrJ8Zpgp9e7W+F2iQrLq5VsUD61+lJYj/zIL939ycGn/+yLoJ721vcj5fguhnBoiuk493us2ltJ+BCkU0LArLDPg1+YIRnfqic8FTBrSq+3qT4JOAMbWUlxbCAn1UzQ7Je8gJYEPwle+ONKdhcgNBxHQUaLQQAmCxjzqZ/nU54Inow+gpeNUktYTYUQvZ5Zo8oMhxPsLff+gOt8Ibv09WgJaUFGy7YS2DaMcr2HvOKwOylYviokmS8K/mJ85hrW4Ifl+CZvNLvIIZct8G9TNNyYL7sZpb39uGpewGz1psEAynA/Kka2O9rvoJ0PvRSIwgHLQ2kM/83N+vLq18gqBfvxyRETPT+DV5Rk+v5Q1TvfiNxJ4+V9lTp/lGwHVEExk3BrFHDaCD9pos= AzureAD+SurajSanathKumarBhar@LAPTOP-QNUBGG8L"
const transit_gw_name = "sao-gw"

// const pvs_management_network     = { "name" = "mgmt_net", "cidr" = "10.81.0.0/24" }
// const pvs_backup_network         = { "name" = "bkp_net", "cidr" = "10.82.0.0/24" }
const cloud_connection_count = "2"
const cloud_connection_speed = "5000"

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:                 t,
		TerraformDir:            defaultExampleTerraformDir,
		ResourceGroup:           resourceGroup,
		Prefix:                  prefix,
		workspace_id:            workspace_id,
		pvs_zone:                pvs_zone,
		pvs_resource_group_name: pvs_resource_group_name,
		ssh_public_key:          ssh_public_key,
		transit_gw_name:         transit_gw_name,
		//		pvs_management_network:   pvs_management_network,
		//		pvs_backup_network:       pvs_backup_network,
		cloud_connection_count: cloud_connection_count,
		cloud_connection_speed: cloud_connection_speed,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	// TODO: Remove this line after the first merge to master branch is complete to enable upgrade test
	t.Skip("Skipping upgrade test until initial code is in master branch")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        "mod-template-upg",
		ResourceGroup: resourceGroup,
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
