#####################################################
# Install Necessary Packages
#####################################################

resource "null_resource" "install_packages" {

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
      "zypper install -y git-core",
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
  depends_on = [null_resource.install_packages]

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
  #"unbuffer ansible-playbook --connection=local -i 'localhost,' ~/.ansible/collections/ansible_collections/ibm/power_linux_sap/playbooks/playbook-sles.yml --extra-vars '@/root/terraform_services_vars.yml' 2>&1 | tee ansible_execution.log ",
  #]
  # }
}
