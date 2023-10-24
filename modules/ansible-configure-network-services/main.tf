##########################################################################################################
# 1. Proxy Client setup
# 2. Register OS
# 3. Install Necessary Packages
# 4. Execute Ansible galaxy role to configure network services (NTP, NFS, DNS, SQUID)
# 5. Update OS and Reboot
##########################################################################################################

locals {
  src_shell_templates_dir   = "${path.module}/templates-shell/"
  src_ansible_templates_dir = "${path.module}/templates-ansible/"
  dst_files_dir             = "/root/terraform_files"
}

##########################################################################################################
# 1. Proxy Client setup
# 2. Register OS
##########################################################################################################

locals {
  src_services_init_tpl_path = "${local.src_shell_templates_dir}/services_init.sh.tftpl"
  dst_services_init_path     = "${local.dst_files_dir}/services_init.sh"
}

resource "terraform_data" "perform_proxy_client_setup" {

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
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_services_init_path
    content = templatefile(
      local.src_services_init_tpl_path,
      {
        "proxy_ip_and_port" : var.perform_proxy_client_setup != null ? "${var.perform_proxy_client_setup["squid_server_ip"]}:${var.perform_proxy_client_setup["squid_port"]}" : ""
        "no_proxy_ip" : var.perform_proxy_client_setup != null ? var.perform_proxy_client_setup["no_proxy_hosts"] : ""
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

##########################################################################################################
# 3. Install Necessary Packages
##########################################################################################################

locals {

  src_install_packages_tpl_path = "${local.src_shell_templates_dir}/install_packages.sh.tftpl"
  dst_install_packages_path     = "${local.dst_files_dir}/install_packages.sh"
}

resource "terraform_data" "install_packages" {
  depends_on = [terraform_data.perform_proxy_client_setup]

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
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_install_packages_path
    content     = templatefile(local.src_install_packages_tpl_path, { "install_packages" : true })
  }

  #######  Execute script: Install packages ############
  provisioner "remote-exec" {
    inline = ["chmod +x ${local.dst_install_packages_path}", local.dst_install_packages_path]
  }
}


##########################################################################################################
# 4. Execute Ansible galaxy role to configure network
# services (NTP, NFS, DNS, Squid)
##########################################################################################################

locals {

  src_configure_network_services_tpl_path           = "${local.src_ansible_templates_dir}/ansible_exec.sh.tftpl"
  dst_configure_network_services_file_path          = "${local.dst_files_dir}/configure_network_services.sh"
  src_playbook_configure_network_services_tpl_path  = "${local.src_ansible_templates_dir}/playbook_configure_network_services.yml.tftpl"
  dst_playbook_configure_network_services_file_path = "${local.dst_files_dir}/playbook_configure_network_services.yml"
}

resource "terraform_data" "execute_ansible_role" {
  depends_on = [terraform_data.install_packages]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  # Creates terraform scripts directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  # Copy playbook template file to target host
  provisioner "file" {
    content     = templatefile(local.src_playbook_configure_network_services_tpl_path, { "server_config" : jsonencode(var.network_services_config) })
    destination = local.dst_playbook_configure_network_services_file_path
  }

  # Copy ansible exec template file to target host
  provisioner "file" {
    content     = templatefile(local.src_configure_network_services_tpl_path, { "ansible_playbook_file" : local.dst_playbook_configure_network_services_file_path, "ansible_log_path" : local.dst_files_dir })
    destination = local.dst_configure_network_services_file_path
  }


  #  Execute script: configure_network_services.sh
  provisioner "remote-exec" {
    inline = ["chmod +x ${local.dst_configure_network_services_file_path}", local.dst_configure_network_services_file_path]
  }
}


##########################################################################################################
# 5. Update OS and Reboot
##########################################################################################################

resource "terraform_data" "update_os" {
  depends_on = [terraform_data.execute_ansible_role]

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
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_services_init_path
    content = templatefile(
      local.src_services_init_tpl_path,
      {
        "proxy_ip_and_port" : var.perform_proxy_client_setup != null ? "${var.perform_proxy_client_setup["squid_server_ip"]}:${var.perform_proxy_client_setup["squid_port"]}" : ""
        "no_proxy_ip" : var.perform_proxy_client_setup != null ? var.perform_proxy_client_setup["no_proxy_hosts"] : ""
      }
    )
  }


  ####### Update OS and Reboot ############
  provisioner "remote-exec" {
    inline = ["chmod +x ${local.dst_services_init_path}", "${local.dst_services_init_path} update_os", ]
  }
}
