#####################################################
# Configure Squid client
#####################################################

resource "null_resource" "perform_proxy_client_setup" {

  count = var.perform_proxy_client_setup != null ? length(var.perform_proxy_client_setup["squid_client_ips"]) : 0

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.perform_proxy_client_setup["squid_client_ips"][count.index]
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "remote-exec" {
    inline = [

      #######  SQUID Forward PROXY CLIENT SETUP ############
      "LINE=$'export http_proxy=http://${var.perform_proxy_client_setup["squid_server_ip"]}:3128\nexport https_proxy=http://${var.perform_proxy_client_setup["squid_server_ip"]}:3128\nexport HTTP_proxy=http://${var.perform_proxy_client_setup["squid_server_ip"]}:3128\nexport HTTPS_proxy=http://${var.perform_proxy_client_setup["squid_server_ip"]}:3128\nexport no_proxy=${var.perform_proxy_client_setup["no_proxy_env"]}'",
      "FILE='/etc/bash.bashrc'",
      "grep -qF -- \"$LINE\" \"$FILE\" || echo \"$LINE\" >> \"$FILE\"",

      ###### Restart Network #######

      "/usr/bin/systemctl restart network ",
    ]
  }
}

#####################################################
# Install Necessary Packages
#####################################################

resource "null_resource" "install_packages" {
  depends_on = [null_resource.perform_proxy_client_setup]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "remote-exec" {
    inline = [

      ##### Install Ansible and git ####
      "zypper install -y python3-pip",
      "pip install -q ansible ",
      "pip install -q awscli"
    ]
  }
}

#####################################################
# Execute Ansible galaxy role to install service
# for SAP installation
#####################################################

locals {
  server_config_option_tmp = merge(var.service_config, { "enable" = true })
  server_config_options    = { for key, value in local.server_config_option_tmp : key => local.server_config_option_tmp[key] }
  server_config_name       = split("_", one([for item in keys(var.service_config) : item if can(regex("enable", item))]))[0]
}

resource "null_resource" "execute_ansible_role" {
  depends_on = [null_resource.install_packages, null_resource.perform_proxy_client_setup]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "file" {

    #### Write service config file under  /root/terraform_services_vars.yml  ####

    content = <<EOF
server_config: {
${local.server_config_name}: ${jsonencode(local.server_config_options)},
}
EOF

    destination = "terraform_${local.server_config_name}_config.yml"
  }

  #provisioner "remote-exec" {
  # inline = [

  ####  Execute ansible roles: server_services_config  ####

  #"ansible-galaxy collection install ibm.power_linux_sap",
  #"unbuffer ansible-playbook --connection=local -i 'localhost,' ~/.ansible/collections/ansible_collections/ibm/power_linux_sap/playbooks/playbook-management.yml --extra-vars '@/root/terraform_${local.server_config_name}_config.yml' 2>&1 | tee ansible_execution.log ",
  #]
  # }
}
