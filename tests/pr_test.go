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
	if err := os.Setenv("TF_VAR_ssh_public_key", sshPublicKey); err != nil {
		tSsh.Fatalf("failed to set TF_VAR_ssh_public_key: %v", err)
	}
	if err := os.Setenv("TF_VAR_ssh_private_key", sshPrivateKey); err != nil {
		tSsh.Fatalf("failed to set TF_VAR_ssh_private_key: %v", err)
	}
	os.Exit(m.Run())
}

func setupOptionsStandardSolution(t *testing.T, prefix string, powervs_zone string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:         t,
		TerraformDir:    defaultExampleTerraformDir,
		Prefix:          prefix,
		ResourceGroup:   resourceGroup,
		Region:          powervs_zone,
		ImplicitDestroy: []string{},
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":                      options.Prefix,
		"powervs_resource_group_name": options.ResourceGroup,
		"external_access_ip":          "0.0.0.0/0",
		"powervs_zone":                options.Region,
		"client_to_site_vpn": map[string]interface{}{
			"enable":                        true,
			"client_ip_pool":                "192.168.0.0/16",
			"vpn_client_access_group_users": []string{},
		},
		"existing_sm_instance_guid":          permanentResources["secretsManagerGuid"],
		"existing_sm_instance_region":        permanentResources["secretsManagerRegion"],
		"existing_certificate_template_name": permanentResources["privateCertTemplateName"],
		"enable_monitoring":                  false,
		"enable_scc_wp":                      true,
		"ansible_vault_password":             "SecurePassw0rd!",
	}

	return options
}

func TestRunBranchStandardExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsStandardSolution(t, "pvs-i-b", "sao04")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunMainStandardExample(t *testing.T) {
	t.Parallel()
	options := setupOptionsStandardSolution(t, "pvs-i-m", "syd04")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
