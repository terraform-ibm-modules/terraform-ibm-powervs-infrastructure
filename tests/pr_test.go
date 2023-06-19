// Tests in this file are run in the PR pipeline
package test

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "solutions/full-stack"

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	// creating ssh keys
	tSsh := new(testing.T)
	rsaKeyPair, _ := ssh.GenerateRSAKeyPairE(tSsh, 4096)
	sshPublicKey := strings.TrimSuffix(rsaKeyPair.PublicKey, "\n") // removing trailing new lines
	sshPrivateKey := "<<EOF\n" + rsaKeyPair.PrivateKey + "EOF"
	os.Setenv("TF_VAR_ssh_public_key", sshPublicKey)
	os.Setenv("TF_VAR_ssh_private_key", sshPrivateKey)
	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       defaultExampleTerraformDir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		Region:             "us-south", // specify default region to skip best choice query
		DefaultRegion:      "us-south",
		BestRegionYAMLPath: "../common-dev-assets/common-go-assets/cloudinfo-region-power-prefs.yaml", // specific to powervs zones
	})

	// query for best zone to deploy powervs example, based on current connection count
	// NOTE: this is why we do not want to run multiple tests in parallel.
	options.Region, _ = testhelper.GetBestPowerSystemsRegionO(options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], options.BestRegionYAMLPath, options.DefaultRegion,
		testhelper.TesthelperTerraformOptions{CloudInfoService: sharedInfoSvc})
	// if for any reason the region is empty at this point, such as error, use default
	if len(options.Region) == 0 {
		options.Region = options.DefaultRegion
	}

	options.TerraformVars = map[string]interface{}{
		"prefix":                      options.Prefix,
		"powervs_resource_group_name": options.ResourceGroup,
		"landing_zone_configuration":  "RHEL",
		"external_access_ip":          "0.0.0.0/0",
		// locking into syd05 due to other data center issues
		//"powervs_zone": "lon06",
		"powervs_zone": options.Region,
	}

	return options
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "pvs-inf")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "pvs-i-up")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
