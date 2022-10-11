variable "vm_template_name" {
  type    = string
  default = "debian11.qcow2"
}

variable "debian_base_image" {
  type    = string
  default = "debian-11-generic-arm64.qcow2"
}

source "qemu" "custom_image" {
  
  # Boot Commands when Loading the ISO file with OVMF.fd file (Tianocore) / GrubV2
#   boot_command = [
#         "e<wait>",
#         "<down><down><down><right><right><right><right><right><right><right><right><right><right>",
#         "<right><right><right><right><right><right><right><right><right><right><right><right><right>",
#         "<right><right><right><right><right><right><right><right><right><right><right><wait>",
#         "install <wait>",
#         " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
#         "debian-installer=en_US.UTF-8 <wait>",
#         "auto <wait>",
#         "locale=en_US.UTF-8 <wait>",
#         "kbd-chooser/method=us <wait>",
#         "keyboard-configuration/xkb-keymap=us <wait>",
#         "netcfg/get_hostname={{ .Name }} <wait>",
#         "netcfg/get_domain=vagrantup.com <wait>",
#         "fb=false <wait>",
#         "debconf/frontend=noninteractive <wait>",
#         "console-setup/ask_detect=false <wait>",
#         "console-keymaps-at/keymap=us <wait>",
#         "grub-installer/bootdev=/dev/sda <wait>",
#         "<f10><wait>"
#   ]
  iso_url   = "https://cloud.debian.org/images/cloud/bullseye/latest/${var.debian_base_image}"
#   iso_checksum = "https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS"
  iso_checksum = "none"
  disk_size = "20G"

  disk_image = true
  # use_backing_file = true
  memory = 4096

  qemu_binary="qemu-system-aarch64"
  
  ssh_password = "vagrant"
  ssh_username = "vagrant"
  ssh_timeout = "20m"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  machine_type = "virt"
  headless = true # to see the process, In CI systems set to true
  accelerator = "hvf" # set to none if no kvm installed
  format = "qcow2"
  cpus = 4
  firmware = "./QEMU_EFI.fd"

  cd_files = ["./user-data", "./meta-data"]
  cd_label = "cidata"
  vm_name = "${var.vm_template_name}"

  qemuargs = [
    ["-bios", "./QEMU_EFI.fd"],
    ["-boot", "strict=on"],
    [ "-cpu", "host" ],
    [ "-monitor", "none" ],
  ]
}

build {
  sources = [ "source.qemu.custom_image" ]
  provisioner "file" {
    source = "../run.sh"
    destination = "/home/vagrant/run.sh"
  }
  provisioner "shell" {
    script = "./setup_debian.sh"
  }

}
