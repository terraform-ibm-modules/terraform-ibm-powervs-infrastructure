#!/bin/bash
############################################################
# Start functions                                          #
############################################################

main::get_os_version() {
  if grep -q "Red Hat" /etc/os-release; then
    readonly LINUX_DISTRO="RHEL"
  else
    main::log_error "Unsupported Linux distribution. Only RHEL is supported."
  fi
  readonly LINUX_VERSION=$(grep VERSION_ID /etc/os-release | awk -F '\"' '{ print $2 }')
}

main::log_info() {
  local log_entry=${1}
  echo "INFO - ${log_entry}"
}

main::log_error() {
  local log_entry=${1}
  echo "ERROR - Deployment exited - ${log_entry}"
  if [[ -n "${on_error}" ]]; then
    exit 1
  else
    exit 0
  fi
}

main::subscription_mgr_check_process() {

  ## check for subscription-manager process
  main::log_info "Sleeping 30 seconds for all subscription-manager process to finish."
  sleep 30

  ## check if zypper is still running
  while pgrep subscription-manager; do
    main::log_info "--- subscription-manager is still running. Waiting 10 seconds before attempting to continue"
    sleep 10s
  done

  ## check if zypper is still running
  while pgrep zypper; do
    main::log_info "--- zypper is still running. Waiting 10 seconds before attempting to continue"
    sleep 10s
  done

}

############################################################
# RHEL : Install Packages                                  #
############################################################
main::install_packages() {

  if [[ ${LINUX_DISTRO} = "RHEL" ]]; then

    main::subscription_mgr_check_process

    ## Install packages
    local rhel_packages="ansible-core expect"

    for package in $rhel_packages; do
      local count=0
      local max_count=3
      while ! yum -y install "${package}"; do
        count=$((count + 1))
        sleep 3
        if [[ ${count} -gt ${max_count} ]]; then
          main::log_error "Failed to install ${package}"
          break
        fi
      done
    done

    ## Download and install collections from ansible-galaxy
    local galaxy_collections="ibm.power_linux_sap:1.1.5 fedora.linux_system_roles:1.73.2 ansible.utils:3.1.0 community.sap_install:1.4.0"

    for collection in $galaxy_collections; do
      local count=0
      local max_count=3
      while ! ansible-galaxy collection install "${collection}" -f; do
        count=$((count + 1))
        sleep 3
        if [[ ${count} -gt ${max_count} ]]; then
          main::log_error "Failed to install ansible galaxy collection ${collection}"
          break
        fi
      done
    done

    # Update OS
    main::log_info 'Updating OS'
    if ! yum update -y; then
      main::log_warning 'OS Update failed'
    fi

    main::log_info "All packages installed successfully"
  fi

}

main::get_os_version
main::install_packages
