#####################################################
# 1. Configure Squid client
# 2. Update OS and Reboot
# 3. Install Necessary Packages
# 4. Execute Ansible galaxy role to install Management
# services for SAP installation
#####################################################

locals {
  scr_scripts_dir = "${path.module}/../terraform_templates"
  dst_scripts_dir = "/root/terraform_scripts"

  src_services_init_tpl_path    = "${local.scr_scripts_dir}/services_init.sh.tftpl"
  dst_services_init_path        = "${local.dst_scripts_dir}/services_init.sh"
  src_install_packages_tpl_path = "${local.scr_scripts_dir}/install_packages.sh.tftpl"
  dst_install_packages_path     = "${local.dst_scripts_dir}/install_packages.sh"

  server_config_option_tmp = merge(var.service_config, { "enable" = true })
  server_config_options    = { for key, value in local.server_config_option_tmp : key => local.server_config_option_tmp[key] }
  server_config_name       = split("_", one([for item in keys(var.service_config) : item if can(regex("enable", item))]))[0]

  ansible_config_mgmt_svs_playbook_name = "powervs-services.yml"
  src_ansible_exec_tpl_path             = "${local.scr_scripts_dir}/ansible_exec.sh.tftpl"
  dst_ansible_exec_path                 = "${local.dst_scripts_dir}/${local.server_config_name}_config.sh"
  dst_ansible_vars_path                 = "${local.dst_scripts_dir}/${local.server_config_name}_config.yml"
}

#####################################################
# 1. Configure Squid client
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
    timeout      = "5m"
  }

  ####### Create Terraform scripts directory ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_services_init_path
    content = templatefile(
      local.src_services_init_tpl_path,
      {
        "proxy_ip_and_port" : "${var.perform_proxy_client_setup["squid_server_ip"]}:${var.perform_proxy_client_setup["squid_port"]}"
        "no_proxy_ip" : var.perform_proxy_client_setup["no_proxy_hosts"]
      }
    )
  }

  #######  Execute script: SQUID Forward PROXY CLIENT SETUP and OS Registration ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_services_init_path}",
      "${local.dst_services_init_path} setup_proxy",
      "${local.dst_services_init_path} register_os"
    ]
  }
}

#####################################################
# 2. Update OS and Reboot
#####################################################

resource "null_resource" "update_os" {
  depends_on = [null_resource.perform_proxy_client_setup]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  ####### Create Terraform scripts directory , Update OS and Reboot ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_services_init_path
    content = templatefile(
      local.src_services_init_tpl_path,
      {
        "proxy_ip_and_port" : "${var.perform_proxy_client_setup["squid_server_ip"]}:${var.perform_proxy_client_setup["squid_port"]}"
        "no_proxy_ip" : var.perform_proxy_client_setup["no_proxy_hosts"]
      }
    )
  }

  ####### Update OS and Reboot ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_services_init_path}",
      "${local.dst_services_init_path} update_os",
    ]
  }
}

resource "time_sleep" "wait_for_reboot" {
  depends_on      = [null_resource.update_os]
  create_duration = "80s"
}

#####################################################
# 3. Install Necessary Packages
#####################################################

resource "null_resource" "install_packages" {
  depends_on = [time_sleep.wait_for_reboot]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }

  ####### Create Terraform scripts directory , Update OS and Reboot ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_install_packages_path
    content = templatefile(
      local.src_install_packages_tpl_path,
      {
        "install_packages" : true
      }
    )
  }

  #######  Execute script: Install packages ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_install_packages_path}",
      local.dst_install_packages_path
    ]
  }
}

#####################################################
# 4. Execute Ansible galaxy role to install service
# for SAP installation
#####################################################

resource "null_resource" "execute_ansible_role" {
  depends_on = [null_resource.install_packages, null_resource.perform_proxy_client_setup]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  ####### Create variable file for ansible playbook execution ############
  provisioner "file" {
    destination = local.dst_ansible_vars_path
    content     = <<EOF
server_config: {
${local.server_config_name}: ${jsonencode(local.server_config_options)},
}
EOF

  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_ansible_exec_path
    content = templatefile(
      local.src_ansible_exec_tpl_path,
      {
        "ansible_playbook_name" : local.ansible_config_mgmt_svs_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute ansible collection to Configure management services  ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_ansible_exec_path}",
      local.dst_ansible_exec_path
    ]
  }
}
