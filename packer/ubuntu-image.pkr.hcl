variable "ssh_public_key" {
  type          = string
  description   = "The SSH public key to add to the VM's authorized_keys file."
}
variable "external_ip" {
  type          = string
  description   = "The IP address to configure on the VM to allow it to be provisioned. The IP address should include the /XX suffix e.g. 10.10.0.10/24"
}
variable "gateway" {
  type          = string
  description   = "The IP address of the default gateway for the VM"
}
variable "user" {
  type          = string
  default       = env("USER")
}
# run 'export VSPHERE_PASSWORD=<password>' to set the password before building the image
variable "vcenter_password" {
  type          = string
  default       = env("VSPHERE_PASSWORD")
  description   = "vCenter password for the 'osinfra2@vsphere.local' password"
}
source "vsphere-clone" "k3s_image_clone" {
  communicator        = "ssh"
  ssh_username        = "ubuntu"
  ssh_agent_auth      = true
  network             = "p0-de-infra-vcen40-k3s"
  convert_to_template = true
  configuration_parameters = {
    "guestinfo.userdata"          = base64encode(file("packer-cloud.cfg"))
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata"          = base64encode(templatefile("packer-metadata", {
                                                              ssh_public_key = file("${var.ssh_public_key}"),
                                                              external_ip="${var.external_ip}",
                                                              gateway="${var.gateway}",
                                                              hostname="packer-build" }))
    "guestinfo.metadata.encoding" = "base64",
    # disk.EnableUUID setting required for vSphere Container Storage Plugin
    "disk.EnableUUID" = "True"
  }
  insecure_connection = "true"
  template            = "DE-Infra-OS/ubuntu-jammy-22.04-cloudimg"
  username            = "osinfra2@vsphere.local"
  password            = "${var.vcenter_password}"
  cluster             = "ATVCEN40-Cluster1"
  folder              = "DE-Infra-OS"
  datastore           = "DatastoreCluster/DS-vCen40_Cluster1-3PAR_15-VV15"
  vcenter_server      = "atvcen40.athtem.eei.ericsson.se"
  vm_name             = "ubuntu-jammy-22.04_new"


}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.vsphere-clone.k3s_image_clone"]
  # ansible provisioner docs: https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible
  provisioner "ansible" {
    playbook_file = "image_update.yml"
    user          = "ubuntu"
    # set use_proxy to false so that ansible connects directly to the VM
    use_proxy = false
    # uncomment to debug the ansible playbook
    # extra_arguments = [ "-vvvv" ]

  }
}