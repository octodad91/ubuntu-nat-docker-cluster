terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  pool      = "images"
  user_data = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_network" "isolated_net" {
  name      = "isolated-net"
  mode      = "nat"
  domain    = "internal"
  addresses = ["192.168.100.0/24"]
  autostart = true
}

resource "libvirt_domain" "docker_uvm" {
  for_each   = var.vm
  name       = each.key
  memory     = each.value.memory
  vcpu       = each.value.vcpu
  cloudinit  = libvirt_cloudinit_disk.commoninit.id
  qemu_agent = true
  
  disk {
    volume_id = libvirt_volume.docker_uvm[each.key].id
  }

  network_interface {
    network_id = libvirt_network.isolated_net.id
  }

  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-noble-base.qcow2"
  pool   = "images"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "docker_uvm" {
  for_each = var.vm
  
  name           = "${each.key}.qcow2"
  pool           = "images"
  base_volume_id = libvirt_volume.ubuntu_base.id
  format         = "qcow2"
  size           = 20 * 1024 * 1024 * 1024
}

output "vm_ips" {
  value = {
    for k, d in libvirt_domain.docker_uvm :
    k => try(d.network_interface[0].addresses[0], null)
  }
}
