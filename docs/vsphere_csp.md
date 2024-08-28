# Deploying vSphere Container Storage Plugin (CSP)


## vSphere CSP requirements

- Required vSphere roles in place and applied correctly.
- K3s nodes have providerId set to vsphere://&lt;node name&gt;
- Datastore used by vSphere CSP must be mounted on all ESXI hosts

### Notes
 1. Following the procedure in [2] didn't work as kubelet arguments *--cloud-provider=external* is deprecated and *--provider-id* didn't set the providerId property on the nodes. The providerId is set by patching the K3s node definition.

2. The cloud controller manager built in to K3s must be disabled, so that the vSphere controller manager can run. The K3s builtin load balancer (Klipper) must also be disabled.




[1] *Getting Started with VMware vSphere
Container Storage Plug-in*, https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-26-getting-started.pdf

[2] *Deploying the vSphere CPI using k3s*, https://cloud-provider-vsphere.sigs.k8s.io/tutorials/deploying-cpi-with-k3s.html

[3] *K3s Server Configuration*, https://docs.k3s.io/reference/server-config