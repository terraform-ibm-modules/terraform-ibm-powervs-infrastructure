#! /bin/bash

set -e

# Paths relative to base directory of script
BASE_DIR=$(dirname "$0")
TERRAFORM_SOURCE_DIR="../resources"
JSON_FILE="../../../catalogValidationValues.json"

(
  # Execute script from base directory
  cd "${BASE_DIR}"
  echo "Generating SSH keys to be used for validation .."

  cd ${TERRAFORM_SOURCE_DIR}
  terraform init || exit 1
  terraform apply -auto-approve || exit 1

  ssh_public_key=$(terraform output -state=terraform.tfstate -raw ssh_public_key)
  ssh_private_key=$(terraform output -state=terraform.tfstate -raw ssh_private_key)
  echo "Appending SSH key values to $(basename ${JSON_FILE}).."
  jq -r --arg ssh_public_key "${ssh_public_key}" --arg ssh_private_key "${ssh_private_key}" '. + {ssh_public_key: $ssh_public_key, ssh_private_key: $ssh_private_key}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
