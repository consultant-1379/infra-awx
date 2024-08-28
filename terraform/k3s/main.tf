terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

variable "vsphere_user" {
  type = string
}

variable "vsphere_server" {
  type = string
}
variable "external_ip_list" {
  type    = list(string)
  default = []

}
variable "external_gateway" {
  type = string
}
variable "externalv6_ip_list" {
  type    = list(string)
  default = []

}
variable "externalv6_gateway" {
  type = string
}
variable "internal_ip_list" {
  type    = list(string)
  default = []
}

variable "internalv6_ip_list" {
  type    = list(string)
  default = []
}
variable "hostnames" {
  type    = list(string)
  default = []
}

provider "vsphere" {
  user = var.vsphere_user
  # password is provided by VSPHERE_PASSWORD 
  # environment variable
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  client_debug         = true
}

data "vsphere_datacenter" "datacenter" {
  name = "ATVCEN40"
}
data "vsphere_datastore" "datastore" {
  name          = "DatastoreCluster/DS-vCen40_Cluster1-3PAR_15-VV15"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "ATVCEN40-Cluster1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "external" {
  name          = "p0-de-infra-vcen40-k3s"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "internal" {
  name          = "p0-de-infra-vcen40-internal"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_virtual_machine" "k3s_template" {
  name          = "DE-Infra-OS/ubuntu-jammy-22.04"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "k3s" {

  name                        = var.hostnames[count.index]
  count                       = 7
  resource_pool_id            = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id                = data.vsphere_datastore.datastore.id
  folder                      = "DE-Infra-OS"
  num_cpus                    = 4
  memory                      = 8192
  guest_id                    = "ubuntu64Guest"
  scsi_type                   = data.vsphere_virtual_machine.k3s_template.scsi_type
  cpu_hot_add_enabled         = true
  cpu_hot_remove_enabled      = true
  memory_hot_add_enabled      = true
  wait_for_guest_net_timeout  = 0
  wait_for_guest_net_routable = false
  cdrom {
    client_device = true
  }
  network_interface {
    network_id = data.vsphere_network.external.id
  }
  network_interface {
    network_id = data.vsphere_network.internal.id
  }
  disk {
    label = "disk0"
    size  = 100
    # thin_provisioned = true
  }

  extra_config = {
    "guestinfo.userdata"          = filebase64("userdata")
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata"          = base64encode(templatefile("metadata.tftpl", { 
                                                              external_ip = "${var.external_ip_list[count.index]}", 
                                                              gateway = "${var.external_gateway}", 
                                                              externalv6_ip = "${var.externalv6_ip_list[count.index]}",
                                                              gatewayv6 = "${var.externalv6_gateway}",
                                                              internal_ip = "${var.internal_ip_list[count.index]}",
                                                              internalv6_ip  = "${var.internalv6_ip_list[count.index]}",
                                                              hostname = var.hostnames[count.index],
                                                              ssh_public_key = file("../../keys/deosinfra.pub") }))
    "guestinfo.metadata.encoding" = "base64",
    # disk.EnableUUID setting required for vSphere Container Storage Plugin
    "disk.EnableUUID" = "True"
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.k3s_template.id
  }

}
