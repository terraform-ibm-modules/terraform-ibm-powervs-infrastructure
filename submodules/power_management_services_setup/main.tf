#####################################################
# Configure Squid client
#####################################################

locals {
  scripts_location     = "${path.module}/scripts"
  squidscript_location = "${local.scripts_location}/squid_proxy.sh"
}

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

  provisioner "file" {
    source      = local.squidscript_location
    destination = "/root/squid_proxy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      #######  SQUID Forward PROXY CLIENT SETUP ############
      "chmod +x /root/squid_proxy.sh",
      "/root/squid_proxy.sh -p ${var.perform_proxy_client_setup["squid_server_ip"]}:3128 -n ${var.perform_proxy_client_setup["no_proxy_env"]}",
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

  provisioner "file" {
    source      = local.squidscript_location
    destination = "/root/squid_proxy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      #######  Install packages ############
      "chmod +x /root/squid_proxy.sh",
      "/root/squid_proxy.sh -i",
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

  provisioner "remote-exec" {
    inline = [

      ####  Execute ansible roles: server_services_config  ####

      "ansible-galaxy collection install ibm.power_linux_sap",
      "unbuffer ansible-playbook --connection=local -i 'localhost,' ~/.ansible/collections/ansible_collections/ibm/power_linux_sap/playbooks/powervs-services.yml --extra-vars '@/root/terraform_${local.server_config_name}_config.yml' 2>&1 | tee ansible_execution.log ",
    ]
  }
}
