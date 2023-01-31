#####################################################
# Configure Squid client
#####################################################

locals {
  scr_scripts_dir = "${path.module}/../terraform_templates"
  dst_scripts_dir = "/root/terraform_scripts"

  src_squid_setup_tpl_path      = "${local.scr_scripts_dir}/services_init.sh.tftpl"
  dst_squid_setup_path          = "${local.dst_scripts_dir}/services_init.sh"
  src_install_packages_tpl_path = "${local.scr_scripts_dir}/install_packages.sh.tftpl"
  dst_install_packages_path     = "${local.dst_scripts_dir}/install_packages.sh"

  ansible_config_mgmt_svs_playbook_name = "powervs-services.yml"
  src_ansible_exec_tpl_path             = "${local.scr_scripts_dir}/ansible_exec.sh.tftpl"
  dst_ansible_exec_path                 = "${local.dst_scripts_dir}/config_mgmt_services.sh"
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

  provisioner "remote-exec" {
    inline = [
      ####### Create Terraform scripts directory ############
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  provisioner "file" {
    destination = local.dst_squid_setup_path
    content = templatefile(
      local.src_squid_setup_tpl_path,
      {
        "proxy_ip_and_port" : "${var.perform_proxy_client_setup["squid_server_ip"]}:${var.perform_proxy_client_setup["squid_port"]}"
        "no_proxy_ip" : var.perform_proxy_client_setup["no_proxy_hosts"]
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      #######  Execute script: SQUID Forward PROXY CLIENT SETUP and OS Registration ############
      "chmod +x ${local.dst_squid_setup_path}",
      local.dst_squid_setup_path

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
      ####### Create Terraform scripts directory ############
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  provisioner "file" {
    destination = local.dst_install_packages_path
    content = templatefile(
      local.src_install_packages_tpl_path,
      {
        "install_packages" : true
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      #######  Execute script: Install packages ############
      "chmod +x ${local.dst_install_packages_path}",
      local.dst_install_packages_path

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
    destination = "terraform_${local.server_config_name}_config.yml"
    content     = <<EOF
server_config: {
${local.server_config_name}: ${jsonencode(local.server_config_options)},
}
EOF

  }

  provisioner "file" {
    destination = local.dst_ansible_exec_path
    content = templatefile(
      local.src_ansible_exec_tpl_path,
      {
        "ansible_playbook_name" : local.ansible_config_mgmt_svs_playbook_name
        "ansible_extra_vars_path" : "${local.dst_scripts_dir}/tf_${local.server_config_name}_config.yml"
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      ####  Execute ansible collection to COnfigure management services  ####

      "chmod +x ${local.dst_ansible_exec_path}",
      local.dst_ansible_exec_path
    ]
  }
}
