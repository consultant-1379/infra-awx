# VMware Dynamic Inventory

The VMware dynamic inventory plugin allows the creation of a dynamic inventory based on information pulled from vCenter. The plugin adds a host to the inventory for each VM in vCenter. 

## Enabling the VMware dynamic inventory plugin
### Prerequisites
- This plugin is part of the [community.vmware](https://galaxy.ansible.com/community/vmware) Ansible collection.
- Depends on the [Pyvmomi](https://github.com/vmware/pyvmomi) python library

### Enable the plugin

To enable the plugin add/update the *enabled_plugins* list under the *inventory* section of the ansible.cfg file.
```ini
[inventory]
enable_plugins = vmware_vm_inventory
```

# Inventory parameters

```yaml
plugin: community.vmware.vmware_vm_inventory
strict: False
hostname: atvcen40.athtem.eei.ericsson.se
username: osinfra2@vsphere.local
password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          62633132373836323533666566306138393539343035383934306663333835613830653433303563
          3438653765646566313365343632653738396431396163620a346239316133616337613763343963
          31646135313434383234303333653761333738646563656233326235646362366265393662373161
          3163363638353537630a306666306266303435316533623863316163356536333232646264373235
          6461
validate_certs: False
compose:
  ansible_host: 'guest.ipAddress'
hostnames:
  - 'config.name'
groups:
  k3s: config.name.startswith("k3s")
  k3s_servers: config.name.startswith("k3s-server")
  k3s_agents: config.name.startswith("k3s-agent")
```

| Parameter | Description |
| --------- | ----------- |
| hostname  | This is the FQDN of the vCenter |
| username  | The name of the user used to access vCenter. |
| password  | The **encrypted** password used to authenticate with vCenter |
| validate_certs | True by default. Set to False if vCenter is using a self-signed SSL/TLS cert |
| compose   | Define inventory variables based on VM properties |
| hostnames | Define the VM property to use for the name of the ansible host |
| groups    | <p>Groups are defined based on VM properties.</p> <p>The <em>groups</em> parameter is a dictionary of groups. <br />Each group is defined by a key/value pair: <ul><li>The <em>key</em> is the name of the group.</li><li>The <em>value</em> is a Jinja/Python expression which is evaluated for each VM. If the expression evaluates to True that VM is included in the group.</li></ul></p><p>For example the <em>k3s</em> group will include any VM where it's <em>config.name</em> property starts with 'k3s'</p> |


The full list of VM properties is here: https://docs.ansible.com/ansible/latest/collections/community/vmware/docsite/vmware_scenarios/vmware_inventory_vm_attributes.html

# References

[1] *Ansible on VMware Guide*, https://docs.ansible.com/ansible/latest/collections/community/vmware/docsite/scenario_guide.html

[2] *Creating groups and variables based on existing inventory*, https://docs.ansible.com/ansible/latest/collections/ansible/builtin/constructed_inventory.html
