# Deploying K3s

## Deploying VMs for K3s

1. Change to the infra-awx/terraform/k3s directory.

    ```
    $ cd infra-awx/terraform/k3s
    ```
2. Set the *VSPHERE_PASSWORD* envrionment variable to the vCenter password for the *osinfra2* user.
    ```
     export VSPHERE_PASSWORD=<password>
    ```
    **Note:** There is a single space before the *export* command. This ensures this command is hidden from
    the shell history.

3. Run the *terraform plan* command to validate the terraform configuration.
    ```
    $ terraform plan -var-file=main.tfvars
    ```
4. Run the *terraform apply* command to deploy the VMs for K3s.
    ```
    $ terraform apply -var-file=main.tfvars
    ```
   **Example Output**
   ```
   ...
   ...
   Plan: 7 to add, 0 to change, 0 to destroy.
    vsphere_virtual_machine.k3s[6]: Creating...
    vsphere_virtual_machine.k3s[1]: Creating...
    vsphere_virtual_machine.k3s[0]: Creating...
    vsphere_virtual_machine.k3s[3]: Creating...
    vsphere_virtual_machine.k3s[5]: Creating...
    vsphere_virtual_machine.k3s[2]: Creating...
    vsphere_virtual_machine.k3s[4]: Creating...
    vsphere_virtual_machine.k3s[6]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[1]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[0]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[3]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[5]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[2]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[4]: Still creating... [10s elapsed]
    vsphere_virtual_machine.k3s[3]: Creation complete after 17s [id=421d6a62-2401-45c2-51a5-21b859af5376]
    vsphere_virtual_machine.k3s[4]: Creation complete after 18s [id=421de45e-e4ec-d30d-3b87-9a620950a27b]
    vsphere_virtual_machine.k3s[1]: Creation complete after 19s [id=421d82a4-4a87-eff7-34a8-85207a629816]
    vsphere_virtual_machine.k3s[5]: Creation complete after 19s [id=421d6859-445c-b6ce-a134-82ab7f63d36c]
    vsphere_virtual_machine.k3s[6]: Still creating... [20s elapsed]
    vsphere_virtual_machine.k3s[2]: Creation complete after 20s [id=421d2178-5c06-1fe3-7c61-53811f160ecf]
    vsphere_virtual_machine.k3s[0]: Still creating... [20s elapsed]
    vsphere_virtual_machine.k3s[6]: Creation complete after 20s [id=421d3604-d252-616f-7969-aeae5efc02e2]
    vsphere_virtual_machine.k3s[0]: Creation complete after 20s [id=421d9686-7acd-354d-37e5-f1e5d4635a68]

    Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
    ```

## Deploying K3s


1. Change to *ansible* subdirectory
   ```
   cd /path/to/infra-awx/ansible
   ```
2. Run the *deploy_k3s.yml playbook to deploy K3s
   ```
   $ ansible-navigator run deploy_k3s.yml -i k3s_inventory.vmware.yml
   ```
   