// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "solutions/standard"

//const quickstartExampleTerraformDir = "solutions/standard-plus-vsi"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	// creating ssh keys
	tSsh := new(testing.T)
	rsaKeyPair, _ := ssh.GenerateRSAKeyPairE(tSsh, 4096)
	sshPublicKey := strings.TrimSuffix(rsaKeyPair.PublicKey, "\n") // removing trailing new lines
	sshPrivateKey := "<<EOF\n" + rsaKeyPair.PrivateKey + "EOF"
	os.Setenv("TF_VAR_ssh_public_key", sshPublicKey)
	os.Setenv("TF_VAR_ssh_private_key", sshPrivateKey)
	os.Exit(m.Run())
}

func setupOptionsStandardSolution(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       defaultExampleTerraformDir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		Region:             "us-south", // specify default region to skip best choice query
		DefaultRegion:      "dal10",
		BestRegionYAMLPath: "./common-go-assets/cloudinfo-region-power-prefs.yaml", // specific to powervs zones
		// temporary workaround for BSS backend issue
		ImplicitDestroy: []string{
			"module.standard.module.landing_zone.module.landing_zone.ibm_resource_group.resource_groups",
		},
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
		"external_access_ip":          "0.0.0.0/0",
		// locking into syd05 due to other data center issues
		//"powervs_zone": "syd05",
		"powervs_zone":                options.Region,
		"existing_sm_instance_guid":   permanentResources["secretsManagerGuid"],
		"existing_sm_instance_region": permanentResources["secretsManagerRegion"],
		"certificate_template_name":   permanentResources["privateCertTemplateName"],
		"enable_monitoring":           true,
		"enable_scc_wp":               false,
	}

	return options
}

func TestRunBranchStandardExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsStandardSolution(t, "pvs-i-b")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunMainStandardExample(t *testing.T) {
	t.Parallel()
	options := setupOptionsStandardSolution(t, "pvs-i-m")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

/*
// quickstart =standard-plus-vsi
func setupOptionsQuickstartSolution(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       quickstartExampleTerraformDir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		Region:             "us-south", // specify default region to skip best choice query
		DefaultRegion:      "dal10",
		BestRegionYAMLPath: "./common-go-assets/cloudinfo-region-power-prefs.yaml", // specific to powervs zones
		// temporary workaround for BSS backend issue
		ImplicitDestroy: []string{
			"module.standard.module.landing_zone.module.landing_zone.ibm_resource_group.resource_groups",
		},
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
		"external_access_ip":          "0.0.0.0/0",
		"tshirt_size": map[string]string{
			"image":       "7300-02-02",
			"tshirt_size": "aix_xs",
		},
		"powervs_zone":                options.Region,
		"existing_sm_instance_guid":   permanentResources["secretsManagerGuid"],
		"existing_sm_instance_region": permanentResources["secretsManagerRegion"],
	}

	return options
}

func TestRunBranchQuickstartExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickstartSolution(t, "pvs-qs-b")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunMainQuickstartExample(t *testing.T) {
	t.Parallel()
	options := setupOptionsQuickstartSolution(t, "pvs-qs-m")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}

}
*/
