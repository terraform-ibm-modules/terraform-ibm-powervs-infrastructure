#!/bin/bash
############################################################
# OS_Support: RHEL only                                    #
# This bash script performs                                #
# - installation of packages                               #
# - ansible galaxy collections.                            #
#                                                          #
############################################################

GLOBAL_RHEL_PACKAGES="rhel-system-roles rhel-system-roles-sap expect"
GLOBAL_GALAXY_COLLECTIONS="ibm.power_linux_sap:>=3.0.0,<4.0.0"

############################################################
# Start functions
############################################################

main::get_os_version() {
  if grep -q "Red Hat" /etc/os-release; then
    readonly LINUX_DISTRO="RHEL"
  else
    main::log_error "Unsupported Linux distribution. Only RHEL is supported."
  fi
  #readonly LINUX_VERSION=$(grep VERSION_ID /etc/os-release | awk -F '\"' '{ print $2 }')
}

main::log_info() {
  local log_entry=${1}
  echo "INFO - ${log_entry}"
}

main::log_error() {
  local log_entry=${1}
  echo "ERROR - Deployment exited - ${log_entry}"
  exit 1
}

main::subscription_mgr_check_process() {

  main::log_info "Sleeping 30 seconds for all subscription-manager process to finish."
  sleep 30

  ## check if subscription-manager is still running
  while pgrep subscription-manager; do
    main::log_info "--- subscription-manager is still running. Waiting 10 seconds before attempting to continue"
    sleep 10s
  done

}

############################################################
# RHEL : Install Packages                                  #
############################################################
main::install_packages() {

  if [[ ${LINUX_DISTRO} = "RHEL" ]]; then

    main::subscription_mgr_check_process

    ## enable repository for RHEL sap roles
    subscription-manager repos --enable="rhel-$(rpm -E %rhel)-for-$(uname -m)-sap-solutions-rpms"

    ## Install packages
    for package in $GLOBAL_RHEL_PACKAGES; do
      local count=0
      local max_count=3
      while ! dnf -y install "${package}"; do
        count=$((count + 1))
        sleep 3
        # shellcheck disable=SC2317
        if [[ ${count} -gt ${max_count} ]]; then
          main::log_error "Failed to install ${package}"
          break
        fi
      done
    done

    ## Download and install collections from ansible-galaxy

    for collection in $GLOBAL_GALAXY_COLLECTIONS; do
      local count=0
      local max_count=3
      while ! ansible-galaxy collection install "${collection}" -f; do
        count=$((count + 1))
        sleep 3
        # shellcheck disable=SC2317
        if [[ ${count} -gt ${max_count} ]]; then
          main::log_error "Failed to install ansible galaxy collection ${collection}"
          break
        fi
      done
    done

    ansible-galaxy collection install -r '/root/.ansible/collections/ansible_collections/ibm/power_linux_sap/requirements.yml' -f
    main::log_info "All packages installed successfully"
  fi

}

############################################################
# Main start here                                          #
############################################################
main::get_os_version
main::install_packages
