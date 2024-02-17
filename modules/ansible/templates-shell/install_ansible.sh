#!/bin/bash
############################################################
# Install and configures ansible                           #
############################################################

############################################################
# Check OS Distribution                                    #
############################################################

if [ -f /etc/SuSE-release ]; then
  OS_DETECTED=SLES
  #  echo "Executing command: cat /etc/SuSE-release"
  echo -e "Detected OS: $OS_DETECTED \n" # "$(cat /etc/SuSE-release)"
fi

if grep --quiet "SUSE Linux Enterprise Server" /etc/os-release; then
  OS_DETECTED=SLES
  #  echo "Executing command: cat /etc/os-release"
  echo -e "Detected OS: $OS_DETECTED \n" # "$(cat /etc/os-release)"
fi

if [ -f /etc/redhat-release ]; then
  OS_DETECTED=RHEL
  #  echo "Executing command: cat /etc/redhat-release"
  echo -e "Detected OS: $OS_DETECTED \n" #"$(cat /etc/redhat-release)"
fi

############################################################
# Helper functions                                         #
############################################################

subscription_mgr_check_process() {
  ##### Check for subscription-manager process
  echo "Sleeping 60 seconds for all subscription-manager process to finish."
  sleep 60
  SUBS_MANAGER_PID="$(pgrep -f subscription-manager)"
  if [ ! -z "$SUBS_MANAGER_PID" ]; then
    echo "A subscription-manager PID process with PID $SUBS_MANAGER_PID is still running, waiting for it to finish. Max Timeout 180 seconds."
    timeout 180 tail --pid=$SUBS_MANAGER_PID -f /dev/null
  fi
  ###### Check for running zypper process
  YUM_PID="$(pidof yum)"
  if [ ! -z "$YUM_PID" ]; then
    echo " A yum process with PID $YUM_PID is still running, waiting for it to finish. Max Timeout 180 seconds."
    timeout 180 tail --pid=$YUM_PID -f /dev/null
  fi
}

suseconnect_check_process() {

  ##### Check for SUSEConnect process
  echo "Sleeping 60 seconds for all SUSEConnect process to finish."
  sleep 60
  SUSECONNECT_PID="$(pgrep SUSEConnect)"
  if [ ! -z "$SUSECONNECT_PID" ]; then
    echo "A SUSEConnect PID process with PID $SUSECONNECT_PID is still running, waiting for it to finish. Max Timeout 180 seconds."
    timeout 180 tail --pid=$SUSECONNECT_PID -f /dev/null
  fi
  ###### Check for running zypper process
  ZYPPER_PID="$(pidof zypper)"
  if [ ! -z "$ZYPPER_PID" ]; then
    echo " A zypper process with PID $ZYPPER_PID is still running, waiting for it to finish. Max Timeout 180 seconds."
    timeout 180 tail --pid=$ZYPPER_PID -f /dev/null
  fi
}

############################################################
# SLES : Install Packages                                  #
############################################################

if [ "$OS_DETECTED" == "SLES" ]; then

  VERSION_ID=$(grep VERSION_ID /etc/os-release | awk -F= '{ print $NF }' | sed 's/\"//g')
  ARCH=$(uname -p)
  suseconnect_check_process

  ##### Activate SuSE packages ####
  zypper --gpg-auto-import-keys ref >/dev/null
  SUSEConnect -p PackageHub/$VERSION_ID/$ARCH >/dev/null
  zypper --gpg-auto-import-keys ref >/dev/null
  SUSEConnect -p sle-module-server-applications/$VERSION_ID/$ARCH >/dev/null
  zypper --gpg-auto-import-keys ref >/dev/null
  SUSEConnect -p sle-module-public-cloud/$VERSION_ID/$ARCH >/dev/null
  zypper --gpg-auto-import-keys ref >/dev/null

  ##### zypper install ansible #####
  echo "Installing ansible package using zypper"
  zypper install -y ansible >/dev/null
  if ! which ansible >/dev/null; then
    echo "ansible installation failed, exiting"
    exit 1
  fi

  echo "All packages are installed successfully"
fi

############################################################
# RHEL : Install Packages                                  #
############################################################

if [ "$OS_DETECTED" == "RHEL" ]; then

  subscription_mgr_check_process

  ##### yum Install ansible-core ####
  echo "Installing ansible using yum"
  yum install -y ansible-core
  if ! which ansible >/dev/null; then
    echo "ansible installation failed, exiting"
    exit 1
  fi

  # Download and install collections from ansible-galaxy
  ansible-galaxy collection install ibm.power_linux_sap:1.1.5 -f
  ansible-galaxy collection install community.general:8.3.0 -f
  ansible-galaxy collection install ansible.utils
  ansible-galaxy collection install ansible.posix

  ##### yum Install expect ####
  echo "Installing expect package using yum"
  yum install -y expect >/dev/null 2>/dev/null
  if ! which unbuffer >/dev/null; then
    echo "expect installation failed, exiting"
    exit 1
  fi

  echo "All packages are installed successfully"
fi
