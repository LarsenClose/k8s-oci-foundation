# Architecture

## Overview

k8s-oci-foundation is a layered infrastructure stack that provisions and manages Kubernetes clusters on Oracle Cloud Infrastructure (OCI). It combines Terraform/OpenTofu for infrastructure provisioning with FluxCD for declarative GitOps cluster management.

## System Architecture

```
                    ┌──────────────────────────────────────────┐
                    │              Developer Workstation        │
                    │  ┌──────────┐  ┌──────────┐  ┌────────┐ │
                    │  │ Taskfile │  │ OpenTofu │  │ age/   │ │
                    │  │  (CLI)   │  │          │  │ SOPS   │ │
                    │  └────┬─────┘  └────┬─────┘  └───┬────┘ │
                    └───────┼─────────────┼────────────┼──────┘
                            │             │            │
              ┌─────────────┼─────────────┼────────────┼──────────┐
              │   OCI       │             │            │          │
              │             ▼             ▼            │          │
              │  ┌─────────────────────────────────┐   │          │
              │  │            VCN                   │   │          │
              │  │  ┌──────────┐  ┌──────────────┐ │   │          │
              │  │  │  Public  │  │   Private     │ │   │          │
              │  │  │  Subnet  │  │   Subnet      │ │   │          │
              │  │  │  (LB,API)│  │  (Workers)    │ │   │          │
              │  │  └────┬─────┘  └──────┬────────┘ │   │          │
              │  └───────┼───────────────┼──────────┘   │          │
              │          │               │              │          │
              │          ▼               ▼              │          │
              │  ┌──────────────────────────────────┐   │          │
              │  │           OKE Cluster             │   │          │
              │  │                                   │   │          │
              │  │  ┌───────────┐  ┌───────────┐    │   │          │
              │  │  │ ARM Pool  │  │ ARM Pool  │    │   │          │
              │  │  │  (A1.Flex)│  │  (A1.Flex)│    │   │          │
              │  │  └───────────┘  └───────────┘    │   │          │
              │  │                                   │   │          │
              │  │  ┌─────────────────────────────┐  │   │          │
              │  │  │       FluxCD (GitOps)        │  │   │          │
              │  │  │  ┌─────────┐ ┌────────────┐ │  │   │          │
              │  │  │  │ Infra   │ │   Apps     │ │  │   │          │
              │  │  │  │ Layer   │ │   Layer    │ │  │   │          │
              │  │  │  └────┬────┘ └──────┬─────┘ │  │   │          │
              │  │  └───────┼─────────────┼───────┘  │   │          │
              │  │          ▼             ▼          │   │          │
              │  │  ┌────────────────────────────┐   │   │          │
              │  │  │     Platform Services       │   │   │          │
              │  │  │ cert-manager │ Istio        │   │   │          │
              │  │  │ Vault        │ nginx-ingress│   │   │          │
              │  │  │ external-dns │              │   │   │          │
              │  │  └────────────────────────────┘   │   │          │
              │  └───────────────────────────────────┘   │          │
              │                                          │          │
              │  ┌───────────────┐                       │          │
              │  │  IAM Policies │  Dynamic groups,      │          │
              │  │               │  volume/LB/metrics     │          │
              │  └───────────────┘                       │          │
              └──────────────────────────────────────────┘          │
                                                                    │
              ┌─────────────────────────────────────────────────────┘
              │
              ▼
     ┌──────────────────┐
     │   Cloudflare DNS  │
     │  Zone + Records   │
     │  Wildcard → LB IP │
     └──────────────────┘
```

## Deployment Layers

### Layer 0: Discovery (optional)

[oci-tf-bootstrap](https://github.com/LarsenClose/oci-tf-bootstrap) auto-discovers OCI tenancy resources (compartments, VCNs, availability domains) and generates a `terraform.tfvars` base configuration.

### Layer 1: Infrastructure (OpenTofu)

Five Terraform modules provision cloud resources in dependency order:

```
oci-network ──► oci-oke ──► oci-iam
                               │
cloudflare-zone ──► cloudflare-records
```

| Module | Creates | Depends On |
|--------|---------|------------|
| `oci-network` | VCN, public/private subnets, security lists, gateways | - |
| `oci-oke` | OKE cluster, ARM node pools, kubeconfig | oci-network |
| `oci-iam` | Dynamic groups, volume/metrics/LB policies | oci-oke |
| `cloudflare-zone` | DNS zone, SSL/TLS settings | - |
| `cloudflare-records` | A/CNAME/wildcard records | cloudflare-zone |

### Layer 2: GitOps Bootstrap (FluxCD)

FluxCD is bootstrapped onto the cluster and watches the `gitops/` directory tree:

```
gitops/clusters/oci-prod/
  ├── flux-system/          # FluxCD components (auto-generated)
  ├── infrastructure.yaml   # Points to ../infrastructure
  └── apps.yaml             # Points to ../apps
```

### Layer 3: Platform Controllers

FluxCD reconciles infrastructure components in dependency order:

```
cert-manager (1.16.2)
    ├── istio (1.24.0)
    ├── vault (1.17.6)
    └── ingress-nginx (4.11.3)
            └── external-dns (1.14.5)
```

Controller ordering is enforced via `dependsOn` fields in HelmRelease manifests. cert-manager deploys first since Istio and Vault both require TLS certificate management.

### Layer 4: Secrets Management

Two-tier secrets architecture:

1. **Git-level** (SOPS + age): Encrypted secrets stored in Git, decrypted by FluxCD at reconciliation time. Used for initial bootstrap values.
2. **Runtime** (HashiCorp Vault): Dynamic secrets for running applications. Vault runs in-cluster and integrates via the Kubernetes auth method.

[genesis](https://github.com/LarsenClose/genesis) handles the initial envelope-encrypted secrets bootstrap.

### Layer 5: Applications

Applications deploy via GitOps using three provided templates:

| Template | Use Case | Key Resources |
|----------|----------|---------------|
| `helm-app` | Helm chart deployments | HelmRelease, Namespace |
| `kustomize-app` | Plain manifests | Deployment, Service, Ingress |
| `stateful-app` | Stateful workloads | StatefulSet, PVC, Service |

## Network Architecture

### Subnet Design

| Subnet | CIDR | Purpose | Internet Access |
|--------|------|---------|-----------------|
| Public | 10.0.0.0/24 | API endpoint, load balancers | Direct (Internet Gateway) |
| Private | 10.0.1.0/24 | Worker nodes | Outbound only (NAT Gateway) |

### Security Lists

**Public subnet** allows inbound:
- TCP 443 (HTTPS)
- TCP 80 (HTTP)
- TCP 6443 (Kubernetes API)
- TCP 10250 (Kubelet, VCN-internal only)

**Private subnet** allows:
- All traffic within VCN CIDR (inter-node communication)
- All outbound

### DNS Flow

```
*.dev.example.com ──► Cloudflare (proxy) ──► OCI LB IP ──► ingress-nginx ──► Istio Gateway ──► Service
```

## Compute Architecture

The cluster uses OCI Ampere A1 ARM instances (VM.Standard.A1.Flex) to stay within the Always Free tier:

- **Default**: 2 node pools, 1 node each, 2 OCPUs / 12GB RAM per node
- **Free tier total**: 4 OCPUs, 24GB RAM (matches the 4 OCPU / 24GB Always Free allocation)
- Nodes run Ubuntu 24.04 Minimal (aarch64)

## Extension Model

This foundation is designed to be extended via application overlays. An overlay adds its own `gitops/apps/` entries and optional Terraform modules without modifying the base:

```
k8s-oci-foundation/          # Base infrastructure
  └── extends to:
      disentangle-network/deploy/  # Disentangle Protocol deployment
      your-app/                    # Your application overlay
```

## Companion Projects

| Project | Role |
|---------|------|
| [oci-tf-bootstrap](https://github.com/LarsenClose/oci-tf-bootstrap) | OCI tenancy resource discovery |
| [genesis](https://github.com/LarsenClose/genesis) | GitOps secrets bootstrap with envelope encryption |
| [disentangle-network/deploy](https://github.com/disentangle-network/deploy) | Disentangle Protocol blockchain network deployment |
| [yubikey-init](https://github.com/LarsenClose/yubikey-init) | Hardware security key provisioning |
