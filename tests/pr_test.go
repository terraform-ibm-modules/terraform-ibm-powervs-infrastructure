// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/random"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "examples/basic"

var prefix = fmt.Sprintf("pvs-%s", strings.ToLower(random.UniqueId()))
var terraformVarsStandard = map[string]interface{}{
	"resource_group": resourceGroup,
	"prefix":         prefix,
}

// Upgrade test must use different prefix to standard test to avoid name clashes
var prefixUpg = prefix + "-upg"
var terraformVarsUpgrade = map[string]interface{}{
	"resource_group": resourceGroup,
	"prefix":         prefixUpg,
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		ResourceGroup: resourceGroup,
		Prefix:        prefix,
		TerraformVars: terraformVarsStandard,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		ResourceGroup: resourceGroup,
		Prefix:        prefixUpg,
		TerraformVars: terraformVarsUpgrade,
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
