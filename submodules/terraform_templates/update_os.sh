#!/bin/bash
############################################################
# Updates the OS to latest level
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

###########################################
# SLES : Update OS                        #
###########################################

if [ "$OS_DETECTED" == "SLES" ]; then
  cp -rp /etc/bash.bashrc /etc/bash.bashrc.bkp
  echo "Updating OS"
  zypper update -y >>os_update.log
  cp -rp /etc/bash.bashrc.bkp /etc/bash.bashrc
  echo "Updating OS Completed"
  echo "Rebooting VM"
  (
    sleep 3
    reboot
  ) &
fi

###########################################
# RHEL : Update OS                        #
###########################################

if [ "$OS_DETECTED" == "RHEL" ]; then

  ##### update os and reboot #####
  echo "Updating OS"
  yum update -y >>os_update.log
  echo "Updating OS Completed"
  echo "Rebooting VM"
  (
    sleep 3
    reboot
  ) &
fi
