#!/bin/bash
############################################################
# Help                                                     #
############################################################

Help()
{
   # Display Help
   echo "Configures proxy on client and Installs ansible"
   echo
   echo "Syntax: scriptTemplate [ -p | -n | -h | -i]"
   echo "options:"
   echo "-p: Proxy Server IP:Port"
   echo "-n: No proxy Ip"
   echo "-i: Install packages"
   echo "-h: Print this Help."
}

exit_abnormal() {                         # Function: Exit with error.
  usage
  exit 1
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
if [[ $# -eq 0 ]] ; then
    Help
    exit 0
fi

while getopts :h?:p:in: flag
do
    case "${flag}" in
		p)
		proxy_ip_and_port=${OPTARG};;

		n)
		no_proxy_ip=${OPTARG};;

      i)
      install_packages=true;;

		:)                                    # If expected argument omitted:
         echo "Error: -${OPTARG} requires an argument."
         exit_abnormal                       # Exit abnormally.
         ;;
         \? | h | *) # Prints help.
         grep " .)\ #" "$0"
                                             # If unknown (any other) option:
         exit_abnormal                       # Exit abnormally.
      ;;
  esac
done

############################################################
# Main Program                                             #
############################################################

if [ -f /etc/SuSE-release ]
then
 OS_DETECTED=SLES
 echo "Executing command: cat /etc/SuSE-release"
 echo -e "Detected OS: $OS_DETECTED \n" "$(cat /etc/SuSE-release)"
fi

if grep --quiet "SUSE Linux Enterprise Server" /etc/os-release;
then
 OS_DETECTED=SLES
 echo "Executing command: cat /etc/os-release"
 echo -e "Detected OS: $OS_DETECTED \n" "$(cat /etc/os-release)"
fi


if [ -f /etc/redhat-release ]
then
 OS_DETECTED=RHEL
 echo "Executing command: cat /etc/redhat-release"
 echo -e "Detected OS: $OS_DETECTED \n" "$(cat /etc/redhat-release)"
fi


###########################################
# SLES Setup                              #
###########################################
if [ "$OS_DETECTED" == "SLES" ]; then

   if [[ $proxy_ip_and_port =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]] ; then

     #######  SQUID Forward PROXY CLIENT SETUP ############
     echo "Proxy Server IP:  $proxy_ip_and_port"
     echo "Setting exports in /etc/bash.bashrc file On SLES"
	  FILE="/etc/bash.bashrc"
	  grep -qx "export http_proxy=http://$proxy_ip_and_port" "$FILE"  || echo "export http_proxy=http://$proxy_ip_and_port"  >> "$FILE"
     grep -qx "export https_proxy=http://$proxy_ip_and_port" "$FILE" || echo "export https_proxy=http://$proxy_ip_and_port" >> "$FILE"
	  grep -qx "export HTTP_proxy=http://$proxy_ip_and_port" "$FILE"  || echo "export HTTP_proxy=http://$proxy_ip_and_port"  >> "$FILE"
	  grep -qx "export HTTPS_proxy=http://$proxy_ip_and_port" "$FILE" || echo "export HTTPS_proxy=http://$proxy_ip_and_port" >> "$FILE"
	  grep -qx "export no_proxy=$no_proxy_ip" "$FILE"                 || echo "export no_proxy=$no_proxy_ip"                 >> "$FILE"

      ###### Restart Network #######

      /usr/bin/systemctl restart network

    fi

    while true
      do
         echo "Waiting for OS Activation"
         OS_Activated="$(SUSEConnect --status | grep  -c "\"status\":\"Not Registered\"")"
		   No_Error="$(SUSEConnect --status | grep -c "error")"
         if [ "$OS_Activated" = 0 ] && [ "$No_Error" = 0 ] ; then
              echo "OS is Registered"
              break;
         fi
      done

    while true
      do
         PID=$(pidof zypper)
         if [ -e /proc/"$PID" ];then
              break;
	     else
              echo "Process: Zypper is still running"
         fi
      done

    ##### Install Ansible and awscli ####
    if [ "$install_packages" = true ] ; then
	      zypper install -y python3-pip
	      pip install -q ansible
	      pip install -q awscli
    fi
fi


###########################################
# RHEL Setup                              #
###########################################
if [ "$OS_DETECTED" == "RHEL" ]; then

   if [[ $proxy_ip_and_port =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]] ; then

      echo "Setting exports in /etc/bashrc and /etc/dnf file On RHEL"
	  FILE="/etc/bashrc"
	  grep -qx "export http_proxy=http://$proxy_ip_and_port" "$FILE"  || echo "export http_proxy=http://$proxy_ip_and_port"  >> "$FILE"
     grep -qx "export https_proxy=http://$proxy_ip_and_port" "$FILE" || echo "export https_proxy=http://$proxy_ip_and_port" >> "$FILE"
	  grep -qx "export HTTP_proxy=http://$proxy_ip_and_port" "$FILE"  || echo "export HTTP_proxy=http://$proxy_ip_and_port"  >> "$FILE"
	  grep -qx "export HTTPS_proxy=http://$proxy_ip_and_port" "$FILE" || echo "export HTTPS_proxy=http://$proxy_ip_and_port" >> "$FILE"
	  grep -qx "export no_proxy=$no_proxy_ip" "$FILE"                 || echo "export no_proxy=$no_proxy_ip"                 >> "$FILE"
	  grep -qx "proxy=http://$proxy_ip_and_port" "$FILE"              || echo "proxy=http://$proxy_ip_and_port"              >> /etc/dnf/dnf.conf

      ###### Restart Network #######

      /usr/bin/systemctl restart NetworkManager

    fi
fi
