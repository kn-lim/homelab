<p align="center">
  <img width="100" style="border-radius: 50%" src="https://raw.githubusercontent.com/kn-lim/kn-lim/refs/heads/main/homelab/icon.png"></img>
  <br>
  <i>Kevin's Personal Homelab</i>
</p>

# Homelab

![Talos](https://img.shields.io/badge/talos-v1.14.4-FF7300?logo=talos&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-v1.37.1-326CE5?logo=kubernetes&logoColor=white)

A definitely over-engineered, but good enough homelab that handles my home infrastructure and Kubernetes clusters.

## Purpose

I have two goals in mind for this homelab:

1. Learn and implement enterprise-grade systems and patterns
2. Repurpose old hardware

## Features

Kubernetes clusters deployed with [Talos Linux](https://github.com/siderolabs/talos) and [Flux](https://github.com/fluxcd/flux2) using [GitHub](https://github.com) as the Git provider, [1Password](https://1password.com) to manage secrets and [Tailscale](https://tailscale.com/) as the primary way for application access.

This repository is managed by [mise](https://github.com/jdx/mise) and [prek](https://github.com/j178/prek) to ensure a standardized environment, alongside [Renovate](https://github.com/apps/renovate) to automate dependency management.

[mise tasks](https://mise.jdx.dev/tasks/) and [gomplate](https://github.com/hairyhenderson/gomplate) are used to generate files for values to be centrally managed and easily modifiable.

### Core Components

<details>
<summary>
<b>Services</b>
</summary>

- [democratic-csi](https://github.com/democratic-csi/democratic-csi)
- [external secrets](https://github.com/external-secrets/external-secrets)
- [flux](https://github.com/fluxcd/flux2)
- [flux-operator](https://github.com/controlplaneio-fluxcd/flux-operator)
- [gpu-operator](https://github.com/nvidia/gpu-operator)
- [kubelet-serving-cert-approver](https://github.com/alex1989hu/kubelet-serving-cert-approver)
- [reloader](https://github.com/stakater/Reloader)
- [velero](https://github.com/vmware-tanzu/velero)
- [versitygw](https://github.com/versity/versitygw)
</details>

<details>
<summary>
<b>Networking</b>
</summary>

- [coredns](https://github.com/coredns/coredns)
- [cert-manager](https://github.com/cert-manager/cert-manager)
- [cilium](https://github.com/cilium/cilium)
- [envoy gateway](https://github.com/envoyproxy/gateway)
- [tailscale kubernetes operator](https://github.com/tailscale/tailscale/)
</details>

<details>
<summary>
<b>Monitoring</b>
</summary>

- [alloy](https://github.com/grafana/alloy)
- [grafana](https://github.com/grafana/grafana)
- [metrics server](https://github.com/kubernetes-sigs/metrics-server)
- [prometheus](https://github.com/prometheus-community/helm-charts/)
</details>

<details>
<summary>
<b>Databases</b>
</summary>

- [cloudnative-pg](https://github.com/cloudnative-pg/cloudnative-pg)
- [valkey](https://github.com/valkey-io/valkey)
</details>

<details>
<summary>
<b>Applications</b>
</summary>

- [tsidp](https://github.com/tailscale/tsidp)
</details>

### Flux

[Flux](https://github.com/fluxcd/flux2) is the GitOps platform for my homelab and is managed by [flux-operator](https://github.com/controlplaneio-fluxcd/flux-operator). Each cluster runs its own Flux instance.

### Gateway API

As some services require direct access rather than through Tailscale, [Envoy Gateway](https://github.com/envoyproxy/gateway) and [Cilium](https://github.com/cilium/cilium) are used to create a gateway for routing to the individual services. This provides an alternative way of accessing services besides Tailscale while on the local network.

### Tailscale

[Tailscale](https://tailscale.com/) is used as the VPN to connect my devices and applications together. The [tailscale kubernetes operator](https://github.com/tailscale/tailscale/) allows my devices to access services within the kubernetes cluster, so that nothing is exposed to the public.

As Tailscale can be used to authenticate users, [tsidp](https://github.com/tailscale/tsidp) acts as the identity provider for any application that allows for SSO.

### Terraform/Terragrunt

Talos Linux is managed with [Terragrunt](https://github.com/gruntwork-io/terragrunt) using the official [Talos Linux Terraform provider](https://github.com/siderolabs/terraform-provider-talos).

The [talos](https://github.com/kn-lim/homelab/tree/main/terraform/_modules/talos) Terraform module contains config patches that are taken from either the official [Talos Linux documentation](https://docs.siderolabs.com/talos/), [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template), [ajaykumar4/cluster-template](https://github.com/ajaykumar4/cluster-template) or specifically added for my homelab.

The [talos stack](https://github.com/kn-lim/homelab/blob/main/terraform/_stacks/talos/terragrunt.stack.hcl) bootstraps the Talos Linux instance and saves the `kubeconfig` and `talosconfig` files using [hooks](https://terragrunt.gruntwork.io/docs/features/hooks/).

## Deploying the Cluster

### Requirements

#### Environment Variables

| Name | Description |
| - | - |
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key |
| `GRAFANA_AUTH` | Grafana Service Account Token |
| `GRAFANA_URL` | Grafana URL |
| `KUBECONFIG` | Kubernetes Config File Path |
| `OP_SERVICE_ACCOUNT_TOKEN` | 1Password Service Account Token |
| `TALOSCONFIG` | Talos Linux Config File Path |
| `TG_BUCKET` | AWS S3 Bucket Name for Terraform Backend |

#### 1Password Secrets

| Name | Description |
| - | - |
| `cloudflare-*` | Cloudflare API Token |
| `discord` | Discord Configurations |
| `op-sa-*` | 1Password Service Account Credentials |
| `tailscale-kubernetes-operator` | Tailscale Kubernetes Operator Credentials |
| `terraform-*` | Credentials for Terraform Providers |
| `tsidp-*` | Tailscale IDP Client Credentials |
| `velero-*` | Velero Credentials |
| `versitygw` | Versity S3 Gateway Credentials |

### Procedure

1. Fill out `clusters.yaml` and run `mise run template:generate` to generate all templated files.
2. Run `mise run terraform:apply terraform/<cluster>/local/talos/generated` to get the cluster ready for bootstrap.
3. Run `mise run bootstrap <cluster>` to bootstrap the cluster.
4. Run `flux get ks -A` to verify every Kustomization is ready.

## Directories

This repository uses the following directory structure that is strictly followed:

```
.mise/                              # mise files
bootstrap/                          # files to bootstrap new clusters
configs/                            # reusable config files
kubernetes/
├─ apps/                            # one directory per namespace
│  ├─ namespace/
│  │  ├─ namespace/                 # namespace manifest and alerts component
│  │  ├─ app/
│  │  │  ├─ app/                    # app manifests
│  │  │  ├─ db/                     # app database, if any
│  │  │  ├─ ks.yaml                 # flux kustomization
├─ clusters/
│  ├─ cluster/                      # flux entry point
│  │  ├─ apps/                      # cluster app list
│  │  ├─ crds/                      # crd app list
│  │  ├─ generated/                 # generated cluster-settings
├─ components/                      # reusable kubernetes resources
terraform/
├─ _modules/                        # terraform modules
├─ _stacks/                         # terragrunt stacks
├─ _units/                          # terragrunt units
├─ platform/
│  ├─ region/                       # or environment/
│  │  ├─ applications/
│  │  │  ├─ generated/              # generated files
clusters.yaml                       # single source of truth for each cluster
```

## Hardware

| Device | Specs | OS | Function |
| - | - | - | - |
| `kerning` (Desktop) | AMD Ryzen 5 5600X, 64GB RAM, NVIDIA GTX 1080 (8GB VRAM) | Unraid 7 | NAS with Talos Linux VM |
| `ellinia` (Laptop) | Lenovo IdeaPad 5 Pro 14ACN6, AMD Ryzen 5 5600U, 16GB RAM | Talos Linux | Standalone Kubernetes Cluster |
| Linksys Velop | - | - | Access Points |
| UniFi Cloud Gateway Ultra | - | - | Router and Firewall |

| Node | Specs | OS | Host | Function |
| - | - | - | - | - |
| `henesys` (Virtual Machine) | 8 CPU, 36GB RAM | Talos Linux | `kerning` | Main Node |
| `ellinia` | 12 CPU, 16GB RAM | Talos Linux | `ellinia` | Node with Low Power Consumption |

## Cost

### Monthly

| Service | Cost per Month | Notes |
| - | - | - |
| 1Password | $6 | Family Plan |

**Total**: $6

## Thanks

This repo is heavily based on the work of [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template) and [ajaykumar4/cluster-template](https://github.com/ajaykumar4/cluster-template). I highly recommend taking a look at those repos if you're interested in setting up a homelab of your own.
