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
  Help
  exit 1
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
if [[ $# -eq 0 ]] ; then
    Help
    exit 1
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

	:)
	    	# If expected argument omitted:
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
   FILE="/etc/bash.bashrc"
   if [[ -n $no_proxy_ip ]] ; then
        grep -qx "export no_proxy=$no_proxy_ip" "$FILE"                 || echo "export no_proxy=$no_proxy_ip"              >> "$FILE"
        source /etc/bash.bashrc
   fi
   if [[ $proxy_ip_and_port =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]] ; then

     #######  SQUID Forward PROXY CLIENT SETUP ############
     echo "Proxy Server IP:  $proxy_ip_and_port"
     echo "Setting exports in /etc/bash.bashrc file On SLES"
     grep -qx "export http_proxy=http://$proxy_ip_and_port" "$FILE"  || echo "export http_proxy=http://$proxy_ip_and_port"  >> "$FILE"
     grep -qx "export https_proxy=http://$proxy_ip_and_port" "$FILE" || echo "export https_proxy=http://$proxy_ip_and_port" >> "$FILE"
     grep -qx "export HTTP_PROXY=http://$proxy_ip_and_port" "$FILE"  || echo "export HTTP_PROXY=http://$proxy_ip_and_port"  >> "$FILE"
     grep -qx "export HTTPS_PROXY=http://$proxy_ip_and_port" "$FILE" || echo "export HTTPS_PROXY=http://$proxy_ip_and_port" >> "$FILE"
     source /etc/bash.bashrc

     ###### Checking if system is registered, if not subscription is done if the instance is ppc64le. This section is only valid for ppc64le instances and not VSI
     OS_Activated="$(SUSEConnect --status | grep  -ci "\"status\":\"Registered\"")"
     if [ "$OS_Activated" -ge 1 ] ; then
        echo "OS is Registered"
     else
        ARCH=$(uname -p)
      ##### check if the system is a x86_64 processor VM
        if [[ "$ARCH" == "x86_64" ]]; then
      #### Wait for registration to complete
 	     count=0
             while [[ $count -le 15 ]]; do
                sleep 60
                OS_Activated="$(SUSEConnect --status | grep  -ci "\"status\":\"Registered\"")"
                if  [[ "$OS_Activated" -ge 1 ]] ; then
        	   echo "OS is Registered"
    		   break;
	        fi
	        count=$(( count +1 ))
	     done
        fi
      ##### check if the system is a HANA or Netweaver VM, should be a ppc64le VM
     	if [[ "$ARCH" == "ppc64le" ]]; then
            SUSEConnect --de-register
            SUSEConnect --cleanup
            mv /var/log/powervs-fls.log /var/log/powervs-fls.log.old
            cmd=$(grep /usr/local/bin/sles-cloud-init.sh < /usr/share/powervs-fls/powervs-fls-readme.md | grep -v RMT_Server_address); $cmd "${proxy_ip_and_port}"
            count=1
	    while [[ $count -le 15 ]]
            do
                count=$(( count + 1 ))
                if grep -i failed  /var/log/powervs-fls.log; then
 		   echo "SLES registration has failed, exiting"
		   exit 1
		fi
                if grep "Successfully completed SLES subscription registration process"  /var/log/powervs-fls.log; then
                    echo "Successfully completed SLES subscription registration process. Done"
		    break;
                fi
		        sleep 60
            done
	 fi
	 if [[ $count -gt 15 ]]; then
	        echo "Timeout: SLES registration process failed, or still ongoing"
	        exit 1
	 fi
         Activation_status="$(SUSEConnect --status | grep -ci "error")"
         if [ "$Activation_status" != 0 ] ; then
              	echo "OS activation Failed"
               	exit 1
         fi
      fi
    fi
 ##### if -i flag  is passed as argument, install ansible, awscli packages
    if [ "$install_packages" == true ] ; then
    ##### Install Ansible and awscli ####
    ##### Activating SuSE packages
        VERSION_ID=$(grep VERSION_ID  /etc/os-release | awk -F= '{ print $NF }' | sed 's/\"//g')
        ARCH=$(uname -p)
        SUSEConnect -p PackageHub/"${VERSION_ID}"/"${ARCH}"
        SUSEConnect -p sle-module-public-cloud/"${VERSION_ID}"/"${ARCH}"
        zypper install -y ansible
        zypper install -y aws-cli
    ##### Verify if each of above packages got installed successfully
    # check if ansible is installed or not
        if ! which ansible >/dev/null; then
            echo "ansible installation failed, exiting"
            exit 1
        fi
        if ! which aws >/dev/null; then
            echo "aws installation failed, exiting"
            exit 1
        fi
    fi
fi
###########################################
# RHEL Setup                              #
###########################################
if [ "$OS_DETECTED" == "RHEL" ]; then
   FILE="/etc/bashrc"
   if [[ -n $no_proxy_ip ]] ; then
        grep -qx "export no_proxy=$no_proxy_ip" "$FILE"                 || echo "export no_proxy=$no_proxy_ip"              >> "$FILE"
        source /etc/bashrc
   fi
   if [[ $proxy_ip_and_port =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]] ; then

     echo "Setting exports in /etc/bashrc and /etc/dnf file On RHEL"
     grep -qx "export http_proxy=http://$proxy_ip_and_port" "$FILE"  || echo "export http_proxy=http://$proxy_ip_and_port"  >> "$FILE"
     grep -qx "export https_proxy=http://$proxy_ip_and_port" "$FILE" || echo "export https_proxy=http://$proxy_ip_and_port" >> "$FILE"
     grep -qx "export HTTP_PROXY=http://$proxy_ip_and_port" "$FILE"  || echo "export HTTP_PROXY=http://$proxy_ip_and_port"  >> "$FILE"
     grep -qx "export HTTPS_PROXY=http://$proxy_ip_and_port" "$FILE" || echo "export HTTPS_PROXY=http://$proxy_ip_and_port" >> "$FILE"
     grep -qx "proxy=http://$proxy_ip_and_port"  /etc/dnf/dnf.conf   || echo "proxy=http://$proxy_ip_and_port"              >> /etc/dnf/dnf.conf
     source /etc/bashrc
     OS_Activated="$(subscription-manager status | grep -ic "Overall Status: Current")"
     if [ "$OS_Activated" -ge 1 ] ; then
        echo "OS is Registered"
     else
        ARCH=$(uname -p)
      ##### check if the system is a x86_64 processor VM
        if [[ "$ARCH" == "x86_64" ]]; then
      #### Wait for registration to complete
 	     count=0
             while [[ $count -le 15 ]]; do
                sleep 60
                OS_Activated="$(subscription-manager status | grep -c "Overall Status: Current")"
                if  [[ "$OS_Activated" -ge 1 ]] ; then
        	        echo "OS is Registered"
    		          break;
	              fi
	              count=$(( count + 1 ))
	            done
        fi
      ##### check if the system is a HANA or Netweaver VM, should be a ppc64le VM
     	if [[ "$ARCH" == "ppc64le" ]]; then
            #subscription-manager --de-register
            #subscription-manager --cleanup
            mv /var/log/powervs-fls.log /var/log/powervs-fls.log.old
            cmd=$(grep /usr/local/bin/rhel-cloud-init.sh < /usr/share/powervs-fls/powervs-fls-readme.md | grep Private.proxy.IP.address | sed "s/Private.proxy.IP.address:3128/$proxy_ip_and_port/g"); $cmd
            count=1
	         while [[ $count -le 15 ]]
            do
                sleep 60
                count=$(( count + 1 ))
                if grep -i failed  /var/log/powervs-fls.log; then
 		              echo "RHEL registration has failed, exiting"
		              exit 1
	            	fi
      ##### Check if registration was successful
                #get the subscription server name from /var/log/powervs-fls.log
                subscription_server=$(grep sap_hana /usr/share/powervs-fls/powervs-fls-readme.md | awk -F"-u" '{ print $NF }' | awk '{ print $1 }')
		            if subscription-manager config | grep "$subscription_server"; then
                   echo "Successfully completed RHEL subscription registration process. Done"
                   break
                fi

            done
	 fi
	 if [[ $count -gt 15 ]]; then
	        echo "Timeout: RHEL registration process failed, or still ongoing"
	        exit 1
	 fi
         Activation_status="$(subscription-manager status |  grep -c "Overall Status: Current")"
         if [ "$Activation_status" == 0 ] ; then
              	echo "OS activation Failed"
               	exit 1
         fi
      fi
    fi
 ##### if -i flag  is passed as argument, install ansible, awscli packages
    if [ "$install_packages" == true ] ; then
    ##### Install Ansible and awscli ####
        yum install -y ansible
        yum install -y awscli
    ##### Verify if each of above packages got installed successfully
    # check if ansible is installed or not
        if ! which ansible >/dev/null; then
            echo "ansible installation failed, exiting"
            exit 1
        fi
        if ! which aws >/dev/null; then
            echo "aws installation failed, exiting"
            exit 1
        fi
    fi
fi
