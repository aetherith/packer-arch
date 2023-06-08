# Arch Linux Desktop
This repository contains [Packer][packer] configuration and [Ansible][ansible]
code to build an [ArchLinux][arch-linux] desktop. The goal is to create a living
record of what is installed and how it is configured to my tastes. Ultimately,
I would like to be able to snap out a raw disk image from Packer and be able to
image a new desktop from it. This is a continuation/improvement of my previous
attempt [packer-ovirt-arch][packer-ovirt-arch].

The work is going to be split into parts as I configure and write tests for each
of the components of a full desktop system and will be detailed below.

## Default Configuration
The default configuration is as follows:

* 1 CPU
* 1GB RAM
* 8GB disk
* LVM configured with a single PV and VG
* Single root LVM partition formatted ext4
* No swap
* Default user of `arch`

## Part 1 - Initial Bootstrap
This configuration set is able to install [ArchLinux][arch-linux] running on both
[QEMU][qemu] and [VirtualBox][vbox] and get as far as a fully installed base
system.

[packer]: https://packer.io/
[ansible]: https://www.ansible.com/
[arch-linux]: https://www.archlinux.org/
[packer-ovirt-arch]: https://github.com/aetherith/packer-ovirt-arch
[qemu]: https://www.qemu.org/
[vbox]: https://www.virtualbox.org/
