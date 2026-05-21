# Talos Linux

## Unraid

### CPU

CPU Mode: `Host Passthrough`
Migratable: `Off`

Pin CPU cores with some headroom for Unraid and other VMs

### Machine

Machine: `Q35-*`
BIOS: `OVMF`
Enable USB boot: `No`
USB Controller: `3.0`

### Disks

Unraid Share Mode: `Virtiofs Mode`

### GPU

1st GPU: `Virtual`

2nd GPU: Point to GPU passed through with IOMMU

Multifunction: `Off`

## Cilium

https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium

## Upgrading Talos

```sh
task talos:upgrade NODE_IP=#### VERSION=v####
```

https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/lifecycle-management/upgrading-talos

Afterwards, run `terragrunt apply` in the specific Talos terraform directory.
