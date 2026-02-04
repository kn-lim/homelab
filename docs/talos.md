# Talos Linux

## Proxmox

https://docs.siderolabs.com/talos/v1.10/platform-specific-installations/virtualized-platforms/proxmox

**System**:

| Name | Value |
|-|-|
| Machine | q35 |
| BIOS | OVMF (UEFI) |
| SCSI Controller | VirtIO SCSI single |
| Qemu Agent | Enabled |

**Disks**:

| Name | Value |
|-|-|
| SSD emulation | Enabled |

**CPU**:

| Name | Value |
|-|-|
| Type | host |

**EFI Disk**:

| Name | Value |
|-|-|
| Pre-Enroll keys | Disabled |

## Cilium

https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium

## Upgrading Talos

Replace `v1.12.2` with the latest version:


```sh
talosctl upgrade --nodes 10.20.30.40 --image ghcr.io/siderolabs/installer:v1.12.2

talosctl upgrade --nodes 10.20.30.40 --image ghcr.io/siderolabs/installer:v1.12.2 --force   # single node clusters
```

https://docs.siderolabs.com/talos/v1.12/configure-your-talos-cluster/lifecycle-management/upgrading-talos
