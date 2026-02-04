# Homelab

A definitely over-engineered, but good enough homelab that handles my home infrastructure and Kubernetes cluster.

## Purpose

I had two goals in mind for this homelab:

1. Learn and implement enterprise-grade systems and patterns
2. Repurpose old hardware

## Features

A Kubernetes cluster deployed with [Talos Linux](https://github.com/siderolabs/talos) and [ArgoCD](https://github.com/argoproj/argo-cd) using [GitHub](https://github.com) as the Git provider, [1Password](https://1password.com) to manage secrets and [Tailscale](https://tailscale.com/) as the primary way for application access.

This repository is managed by [mise](https://github.com/jdx/mise) and [pre-commit](https://github.com/pre-commit/pre-commit) to ensure a standardized environment, alongside [Renovate](https://github.com/apps/renovate) to automate dependency management.

[Task](https://github.com/go-task/task) and [gomplate](https://github.com/hairyhenderson/gomplate) are used to generate Kubernetes manifests and Terragrunt HCL files for values to be centrally managed and easily modifiable.

**Core Components**:

- [argocd](https://github.com/argoproj/argo-cd)
- [cilium](https://github.com/cilium/cilium)
- [coredns](https://github.com/coredns/coredns)
- [external secrets](https://github.com/external-secrets/external-secrets)
- [grafana](https://github.com/grafana/grafana)
- [kubelet-serving-cert-approver](https://github.com/alex1989hu/kubelet-serving-cert-approver)
- [local-path-provisioner](https://github.com/rancher/local-path-provisioner)
- [metrics server](https://github.com/kubernetes-sigs/metrics-server)
- [prometheus](https://github.com/prometheus-community/helm-charts/)
- [reloader](https://github.com/stakater/Reloader)
- [tailscale kubernetes operator](https://github.com/tailscale/tailscale/)
- [tsidp](https://github.com/tailscale/tsidp)

### ArgoCD

[ArgoCD](https://github.com/argoproj/argo-cd) is the GitOps platform for my homelab and is deployed using Kustomize and Helm.

The ApplicationSet in [`kubernetes/overlays/homelab/prod/argo/argocd/homelab-applicationset.yaml`](https://github.com/kn-lim/homelab/blob/main/kubernetes/overlays/homelab/prod/argo/argocd/homelab-applicationset.yaml) generates all ArgoCD Applications and must be defined there.

### Terragrunt

Talos Linux is managed with [Terragrunt](https://github.com/gruntwork-io/terragrunt) using the official [Talos Linux Terraform provider](https://github.com/siderolabs/terraform-provider-talos).

The [talos](https://github.com/kn-lim/homelab/tree/main/terraform/_modules/talos) Terraform module contains config patches that are taken from either the official [Talos Linux documentation](https://docs.siderolabs.com/talos/), [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template), [ajaykumar4/cluster-template](https://github.com/ajaykumar4/cluster-template) or specifically added for my homelab.

The [talos stack](https://github.com/kn-lim/homelab/blob/main/terraform/homelab/_stacks/talos/terragrunt.stack.hcl) bootstraps the Talos Linux instance, saves the `kubeconfig` and `talosconfig` files using [hooks](https://terragrunt.gruntwork.io/docs/features/hooks/), then creates resources to prepare the kubernetes cluster for deployments.

### Tailscale

[Tailscale](https://tailscale.com/) is used as the VPN to connect my devices and applications together. The [tailscale kubernetes operator](https://github.com/tailscale/tailscale/) allows my devices to access services within the kubernetes cluster, so that nothing is exposed to the public.

As Tailscale can be used to authenticate users, [tsidp](https://github.com/tailscale/tsidp) acts as the identity provider for any application that allows for SSO.

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
| `argocd-ssh` | ArgoCD SSH Credentials for GitHub Access |
| `op-sa-kubernetes-token` | 1Password Kubernetes Service Account Token |
| `tailscale-kubernetes-operator` | Tailscale Kubernetes Operator Credentials |
| `tsidp-*` | Tailscale IDP Client Credentials |

### Procedure

0. Fill out `clusters.yaml` and run `task template:generate` to generate all templated files.
1. Run `terragrunt stack generate` and `terragrunt stack run apply` in `terraform/homelab/prod/talos` to a Talos Linux instance waiting to be bootstrapped.
    - This will create a `homelab-prod.kubeconfig` and `homelab-prod.talosconfig` in the repository's root level.
2. Run `task kubernetes:build-apply` in `kubernetes/bases/namespaces` to create the required namespaces.
3. Run `task kubernetes:build-apply` in `kubernetes/overlays/homelab/prod/kube-system/coredns` to install CoreDNS.
4. Run `task kubernetes:build-apply` in `kubernetes/overlays/homelab/prod/kube-system/cilium` to install Cilium.
5. Run `task kubernetes:build-apply` in `kubernetes/overlays/homelab/prod/argo/argocd` to install ArgoCD and all other applications.

## Directories

This repository uses the following directory structure that are strictly followed:

```
configs/                        # reusable config files
docs/                           # documentation
kubernetes/
├─ bases/                       # kustomize bases
│  ├─ applications/
├─ overlays/                    # kustomize overlays
│  ├─ cluster/
│  │  ├─ namespace/
│  │  │  ├─ applications/
│  │  │  │  ├─ generated/       # generated files
terraform/
├─ _modules/                    # terraform modules
├─ _stacks/                     # terragrunt stacks
├─ _units/                      # terragrunt units
├─ platform/
│  ├─ region/
│  │  ├─ applications/
│  │  │  ├─ generated/          # generated files
```

## Hardware

| Device | Specs | OS | Function |
| - | - | - | - |
| Desktop - `proxmox` | AMD Ryzen 5 5600X, 64GB RAM | Proxmox VE | Hypervisor |
| Linksys Velop | - | - | Access Points |
| UniFi Cloud Gateway Ultra | - | - | Router and Firewall |

| Node | Specs | OS | Host | Function |
| - | - | - | - | - |
| VM - `homelab` | 6 CPU, 40GB RAM | Talos Linux | `proxmox` | Control Plane Node |

## Goals

- [x] Use [Terragrunt Stacks](https://terragrunt.gruntwork.io/docs/features/stacks/)
- [ ] [Argo Events](https://github.com/argoproj/argo-events) to handle Webhooks
- [ ] [Argo Workflows](https://github.com/argoproj/argo-workflows) for CI/CD
- [ ] Setup Monitoring and Alerts for all Services
- [ ] Setup Homelab Development Cluster
- [ ] Setup [Kargo](https://github.com/akuity/kargo)
- [ ] Setup a NAS

## Thanks

This repo is heavily based on the work of [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template) and [ajaykumar4/cluster-template](https://github.com/ajaykumar4/cluster-template). I highly recommend taking a look at those repos if you're interested in setting up a homelab of your own.
