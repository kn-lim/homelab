<p align="center">
  <img width="100" style="border-radius: 50%" src="https://raw.githubusercontent.com/kn-lim/kn-lim/refs/heads/main/homelab/icon.png"></img>
  <br>
  <i>Kevin's Personal Homelab</i>
</p>

# Homelab

![Talos](https://img.shields.io/badge/talos-v1.14.1-FF7300?logo=talos&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-v1.37.0-326CE5?logo=kubernetes&logoColor=white)
![Go](https://img.shields.io/badge/go-v1.27-0e7fbf?logo=go&logoColor=white)

A definitely over-engineered, but good enough homelab that handles my home infrastructure and Kubernetes cluster.

## Purpose

I have two goals in mind for this homelab:

1. Learn and implement enterprise-grade systems and patterns
2. Repurpose old hardware

## Features

A Kubernetes cluster deployed with [Talos Linux](https://github.com/siderolabs/talos) and [ArgoCD](https://github.com/argoproj/argo-cd) using [GitHub](https://github.com) as the Git provider, [1Password](https://1password.com) to manage secrets and [Tailscale](https://tailscale.com/) as the primary way for application access.

This repository is managed by [mise](https://github.com/jdx/mise) and [prek](https://github.com/j178/prek) to ensure a standardized environment, alongside [Renovate](https://github.com/apps/renovate) to automate dependency management.

[Task](https://github.com/go-task/task) and [gomplate](https://github.com/hairyhenderson/gomplate) are used to generate Kubernetes manifests and Terragrunt HCL files for values to be centrally managed and easily modifiable.

### Core Components

<details>
<summary>
<b>Services</b>
</summary>

- [argo events](https://github.com/argoproj/argo-events)
- [argo workflows](https://github.com/argoproj/argo-workflows)
- [argocd](https://github.com/argoproj/argo-cd)
- [democratic-csi](https://github.com/democratic-csi/democratic-csi)
- [external secrets](https://github.com/external-secrets/external-secrets)
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
- [gateway api](https://github.com/kubernetes-sigs/gateway-api)
- [tailscale kubernetes operator](https://github.com/tailscale/tailscale/)
- [traefik](https://github.com/traefik/traefik)
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

### ArgoCD

[ArgoCD](https://github.com/argoproj/argo-cd) is the GitOps platform for my homelab and is deployed using Kustomize and Helm.

The ApplicationSets in [`kubernetes/overlays/homelab/argocd/`](https://github.com/kn-lim/homelab/tree/main/kubernetes/overlays/homelab/argocd) (`applicationset-platform.yaml` and `applicationset-apps.yaml`) discover all applications by scanning for `.app.yaml` files in each app's overlay directory.

### CI/CD

As the homelab cluster is not publicly available, the GitHub webhook points to an AWS API Gateway connected to an AWS Lambda function. The function validates the request and forwards it as a message to an AWS SQS queue. This way, [Argo Events](https://github.com/argoproj/argo-events) is able to read the message and runs the [ci.yaml workflow](https://github.com/kn-lim/homelab/blob/main/kubernetes/bases/workflows/ci.yaml) using [Argo Workflows](https://github.com/argoproj/argo-workflows) to apply the changes.

### Gateway API

As some services require direct access rather than through Tailscale, [Traefik](https://github.com/traefik/traefik) and [Cilium](https://github.com/cilium/cilium) are used to create a gateway using the [gateway api](https://github.com/kubernetes-sigs/gateway-api) for routing to the individual services. This provides an alternative way of accessing services besides Tailscale while on the local network.

### Tailscale

[Tailscale](https://tailscale.com/) is used as the VPN to connect my devices and applications together. The [tailscale kubernetes operator](https://github.com/tailscale/tailscale/) allows my devices to access services within the kubernetes cluster, so that nothing is exposed to the public.

As Tailscale can be used to authenticate users, [tsidp](https://github.com/tailscale/tsidp) acts as the identity provider for any application that allows for SSO.

### Backups

[Velero](https://github.com/vmware-tanzu/velero) backs up both clusters. [versitygw](https://github.com/versity/versitygw) in `homelab` is the S3 target. It stores each object as a plain file on the `kubernetes-array` share, so the backups are readable without Velero. Each cluster has its own bucket and IAM user (`velero-homelab` and `velero-homelab-lenovo`). The laptop reaches the gateway at `https://versitygw.knlim.dev`. The `velero-daily` schedule runs at 03:00 and keeps each backup for 14 days.

#### Gateway Setup

Do this only if `/data/iam` is lost. Use the root credentials from the `versitygw` pod. Create one user per cluster. The role `user` cannot create buckets, so create each bucket with `-o` set to the owner's access key.

```bash
kubectl -n versitygw exec deploy/versitygw -- sh -c '
  versitygw admin --endpoint-url http://localhost:7070 -a $ROOT_ACCESS_KEY -s $ROOT_SECRET_KEY \
    create-user -a <access key> -s <secret key> -r user
  versitygw admin --endpoint-url http://localhost:7070 -a $ROOT_ACCESS_KEY -s $ROOT_SECRET_KEY \
    create-bucket --bucket velero-<cluster> -o <access key>'
```

#### Kopia Password

The `repository_password` field in each cluster's 1Password item encrypts that cluster's backups. Never change it.

#### Excluded Data

Velero skips these volumes:

- `hostPath` volumes, which are the media share (immich library, romm games, jellyfin media)
- The immich ML `cache` and `ollama-data`
- `ext-vchord`, `scratch-data` and `shm` on Postgres

Postgres runs `pg_dumpall` to `/var/lib/postgresql/data/velero-dumpall.sql` in a pre-backup hook. The dump is part of the data volume backup.

#### Manual Backup

```bash
velero backup create <name> --exclude-namespaces velero,versitygw \
  --resource-policies-configmap velero-volume-policy --ttl 2160h --wait
```

#### Cold Backup Before a Migration

Velero copies only volumes that a running pod mounts. For a clean backup of stateful apps, stop the apps and mount their volumes with a holder pod.

1. Pause ArgoCD. It manages both clusters.

   ```bash
   kubectl --context admin@homelab -n argocd scale statefulset argocd-application-controller --replicas 0
   ```

2. Scale the Deployments and StatefulSets of each stateful app to 0. Skip Postgres, which uses the hook.
3. Create a `velero-holder` pod in each namespace. It must mount every PVC of that namespace.

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: velero-holder
     namespace: <namespace>
   spec:
     containers:
       - name: holder
         image: busybox:1.37.0
         command: ["sleep", "infinity"]
         volumeMounts:
           - name: data
             mountPath: /data
     volumes:
       - name: data
         persistentVolumeClaim:
           claimName: <pvc>
   ```

   Do not use `immich` or `ollama` here unless you want their caches. Holder pods ignore the exclude annotations.
4. Run the manual backup.
5. Delete the holder pods and scale the apps back up.
6. Scale ArgoCD back to 1 replica.

#### Restore

```bash
velero restore create --from-backup <backup> --include-namespaces <namespace> \
  --resource-modifier-configmap argocd-tracking-strip
```

Velero restores volume data through the restored pods. The restore must include the workload or the holder pod, not only the PVC. Restore after ArgoCD is gone or paused. The modifier ConfigMap drops the ArgoCD tracking annotations.

#### Renamed Apps

To rename a namespace, add `--namespace-mappings old:new`. Velero has no flag to rename a PVC or a workload. Restore into `old-restore`, scale the workload to 0, copy the data into the new PVC with a one-off pod, then delete the staging namespace. The simplest way is to keep the PVC names.

#### Cautions After a Restore

- A namespace-mapped restore of `postgres` also copies the cnpg operator Deployment. Scale it to 0 in the new namespace.
- A restored `otterwiki` brings back its git sync CronJob. Suspend it.
- Never start a restored copy of an app with a Tailscale sidecar (`adguardhome`) while the original runs. Both would use the same tailnet identity.
- Restored PVCs on `local-data` leave Released PVs behind after you delete the namespace.

#### Cluster Rename

Create a new bucket and user for the new cluster name. Add the old bucket as a second BackupStorageLocation with `accessMode: ReadOnly`. If the storage class names change, map them with the Velero change-storage-class ConfigMap.

#### Rebuild Order for `homelab`

1. External Secrets
2. democratic-csi
3. versitygw
4. Velero, from Git

Velero then sees the existing backups on the array. Restore the stateful apps one by one.

### Terraform/Terragrunt

Talos Linux is managed with [Terragrunt](https://github.com/gruntwork-io/terragrunt) using the official [Talos Linux Terraform provider](https://github.com/siderolabs/terraform-provider-talos).

The [talos](https://github.com/kn-lim/homelab/tree/main/terraform/_modules/talos) Terraform module contains config patches that are taken from either the official [Talos Linux documentation](https://docs.siderolabs.com/talos/), [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template), [ajaykumar4/cluster-template](https://github.com/ajaykumar4/cluster-template) or specifically added for my homelab.

The [talos stack](https://github.com/kn-lim/homelab/blob/main/terraform/_stacks/talos/terragrunt.stack.hcl) bootstraps the Talos Linux instance, saves the `kubeconfig` and `talosconfig` files using [hooks](https://terragrunt.gruntwork.io/docs/features/hooks/), then creates resources to prepare the kubernetes cluster for deployments.

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
| `discord` | Discord Configurations |
| `op-sa-*` | 1Password Service Account Credentials |
| `tailscale-kubernetes-operator` | Tailscale Kubernetes Operator Credentials |
| `terraform-*` | Credentials for Terraform Providers |
| `tsidp-*` | Tailscale IDP Client Credentials |
| `velero-homelab` | Velero Credentials for the `homelab` Bucket |
| `velero-homelab-lenovo` | Velero Credentials for the `homelab-lenovo` Bucket |
| `versitygw` | versitygw Root Credentials |

### Procedure

0. Fill out `clusters.yaml` and run `task template:generate` to generate all templated files.
1. Run `terragrunt stack generate` in `terraform/homelab/local/talos` to generate the stack files.
2. Run `terragrunt apply` in `terraform/homelab/local/talos/generated/.terragrunt-stack/talos/.terragrunt-stack/talos` once the Talos Linux instance is waiting to be bootstrapped.
    - This will create a `homelab-local.kubeconfig` and `homelab-local.talosconfig` in the repository's root level.
3. Run `terragrunt stack run apply` in `terraform/homelab/local/talos` to finish the rest of the Talos Linux deployment.
4. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/coredns` to install CoreDNS.
5. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/cilium` to install Cilium.
6. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/kubelet-serving-cert-approver` to install kubelet-serving-cert-approver.
7. Run `task kubernetes:build-apply-server-side DIR=kubernetes/overlays/homelab/external-secrets` to install External Secrets.
8. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/democratic-csi-data` to install democratic-csi.
9. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/tailscale-operator NAMESPACE=tailscale` to install Tailscale Kubernetes Operator.
10. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/tsidp NAMESPACE=tsidp` to install tsidp.
11. Update `clusters.yaml` with the new `ts-dns` nameserver IP address and run `task template:generate`
12. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/coredns` to update CoreDNS.
13. Run `task kubernetes:build-apply DIR=kubernetes/overlays/homelab/argocd NAMESPACE=argocd` to install ArgoCD and all other applications.

## Directories

This repository uses the following directory structure that are strictly followed:

```
configs/                            # reusable config files
docs/                               # documentation
kubernetes/
├─ bases/                           # kustomize bases
│  ├─ applications/
│  ├─ workflows/                    # argo workflows manifests
├─ overlays/                        # kustomize overlays
│  ├─ cluster/
│  │  ├─ applications/
│  │  │  ├─ generated/              # generated files
terraform/
├─ _modules/                        # terraform modules
├─ _stacks/                         # terragrunt stacks
├─ _units/                          # terragrunt units
├─ platform/
│  ├─ region/                       # or environment/
│  │  ├─ applications/
│  │  │  ├─ generated/              # generated files
```

## Hardware

| Device | Specs | OS | Function |
| - | - | - | - |
| PC - `homelab` | AMD Ryzen 5 5600X, 64GB RAM, NVIDIA GTX 1080 (8GB VRAM) | Unraid 7 | NAS with Talos Linux VM |
| Laptop - `homelab-lenovo` | Lenovo IdeaPad 5 Pro 14ACN6, AMD Ryzen 5 5600U, 16GB RAM | Talos Linux | Standalone Kubernetes Cluster |
| Linksys Velop | - | - | Access Points |
| UniFi Cloud Gateway Ultra | - | - | Router and Firewall |

| Node | Specs | OS | Host | Function |
| - | - | - | - | - |
| VM - `homelab-talos` | 8 CPU, 36GB RAM | Talos Linux | `homelab` | Main Node |
| Laptop - `homelab-lenovo` | 12 CPU, 16GB RAM | Talos Linux | `homelab-lenovo` | Node with Low Power Consumption |

## Cost

### Monthly

| Service | Cost per Month | Notes |
| - | - | - |
| 1Password | $6 | Family Plan |
| AWS Lambda | $0 | Usage under Free Tier |
| AWS SQS | $0 | Usage under Free Tier |

**Total**: $6

## Goals

- [x] Use [Terragrunt Stacks](https://terragrunt.gruntwork.io/docs/features/stacks/)
- [x] Setup a NAS with Unraid
- [x] [Argo Events](https://github.com/argoproj/argo-events) to handle Webhooks
- [x] [Argo Workflows](https://github.com/argoproj/argo-workflows) for CI/CD
- [ ] Setup [Kargo](https://github.com/akuity/kargo) for custom apps
- [ ] Setup Monitoring and Alerts for all Services

## Thanks

This repo is heavily based on the work of [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template) and [ajaykumar4/cluster-template](https://github.com/ajaykumar4/cluster-template). I highly recommend taking a look at those repos if you're interested in setting up a homelab of your own.
