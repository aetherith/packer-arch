packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
    virtualbox = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/virtualbox"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  arch_version = "${formatdate("YYYY.MM", timestamp())}.01"

  iso_url          = "https://mirror.arizona.edu/archlinux/iso/${local.arch_version}/archlinux-${local.arch_version}-x86_64.iso"
  iso_checksum_url = "https://mirror.arizona.edu/archlinux/iso/${local.arch_version}/sha256sums.txt"

  vm_name                  = "archlinux-${local.arch_version}"
  default_user_pub_key_url = "http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.default_user_pub_key}"
  disk_size_mb             = "${var.disk_size * 1024}"
}

variable "headless" {
  type    = bool
  default = false
}

variable "default_user" {
  type    = string
  default = "arch"
}

variable "default_user_pub_key" {
  type    = string
  default = "ssh.pub"
}

variable "output_directory" {
  type    = string
  default = "./build"
}

variable "ssh_timeout" {
  type    = string
  default = "20m"
}

variable "memory" {
  type    = number
  default = 1024
}

variable "disk_size" {
  type    = number
  default = 8
}

source "qemu" "arch" {
  vm_name      = local.vm_name
  iso_url      = local.iso_url
  iso_checksum = "file:${local.iso_checksum_url}"

  headless         = var.headless
  accelerator      = "kvm"
  output_directory = "${var.output_directory}/kvm"
  memory           = var.memory
  disk_size        = "${var.disk_size}G"
  disk_interface   = "ide"
  format           = "qcow2"

  http_directory = "srv"
  boot_wait      = "5s"
  boot_command = [
    "<enter><wait10><wait10><wait10><wait10>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup-ssh.sh<enter><wait5>",
    "/usr/bin/bash ./setup-ssh.sh ${var.default_user} ${local.default_user_pub_key_url}<enter>"
  ]
  ssh_username     = var.default_user
  ssh_agent_auth   = true
  ssh_timeout      = var.ssh_timeout
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

source "virtualbox-iso" "arch" {
  vm_name      = local.vm_name
  iso_url      = local.iso_url
  iso_checksum = "file:${local.iso_checksum_url}"

  headless             = var.headless
  output_directory     = "${var.output_directory}/vbox"
  guest_os_type        = "ArchLinux_64"
  guest_additions_mode = "disable"
  memory               = var.memory
  disk_size            = local.disk_size_mb
  hard_drive_interface = "ide"
  format               = "ova"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"]
  ]

  http_directory = "srv"
  boot_wait      = "5s"
  boot_command = [
    "<enter><wait10><wait10><wait10><wait10>",
    "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup-ssh.sh<enter><wait5>",
    "/usr/bin/bash ./setup-ssh.sh ${var.default_user} ${local.default_user_pub_key_url}<enter>"
  ]
  ssh_username     = var.default_user
  ssh_agent_auth   = true
  ssh_timeout      = var.ssh_timeout
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["source.qemu.arch", "source.virtualbox-iso.arch"]

  provisioner "ansible" {
    playbook_file = "./provision/bootstrap.yml"
    extra_arguments = [
      "--extra-vars", "arch_bootstrap_default_user=${var.default_user}",
      "--extra-vars", "arch_bootstrap_default_user_public_key=../srv/${var.default_user_pub_key}",
    ]
    user      = var.default_user
    use_proxy = false
  }
}
