# K8s-OCI-Foundation

[![CI](https://github.com/LarsenClose/k8s-oci-foundation/actions/workflows/ci.yml/badge.svg)](https://github.com/LarsenClose/k8s-oci-foundation/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-%3E%3D1.6.0-purple.svg)](https://opentofu.org/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-326CE5.svg)](https://kubernetes.io/)

Production-grade Kubernetes infrastructure on Oracle Cloud Infrastructure (OCI) with GitOps, secrets management, and service mesh - designed as a reusable foundation for any workload.

## Overview

k8s-oci-foundation provides a complete, opinionated infrastructure stack for deploying Kubernetes clusters on OCI. It's designed to be:

- **Reusable**: Generic infrastructure with no application-specific assumptions
- **Secure**: Zero hardcoded secrets, SOPS+age encryption, Vault integration
- **Cost-optimized**: Targets OCI Always Free tier with ARM compute
- **GitOps-native**: FluxCD for declarative cluster state management
- **Extensible**: Clean extension points for application overlays

## Project Suite

This project is part of a coordinated infrastructure suite:

```
yubikey-init -> genesis-operator -> oci-tf-bootstrap -> k8s-oci-foundation -> disentangle-network/deploy

┌─────────────────────┐
│    yubikey-init      │  Hardware key provisioning
└──────────┬──────────┘
           │ GPG keys
           ▼
┌─────────────────────┐
│  genesis-operator   │  Secrets bootstrap
└──────────┬──────────┘
           │ envelope-encrypted age key
           ▼
┌─────────────────────┐
│   oci-tf-bootstrap  │  Auto-discover OCI tenancy resources
└──────────┬──────────┘
           │ generates Terraform base
           ▼
┌─────────────────────┐
│ k8s-oci-foundation  │  Generic Kubernetes infrastructure (this project)
└──────────┬──────────┘
           │ extends
           ▼
┌──────────────────────────┐
│ disentangle-network/deploy│  Disentangle Protocol deployment (optional)
└──────────────────────────┘
```

## Features

| Feature | Description |
|---------|-------------|
| **OCI Discovery** | Integrates with `oci-tf-bootstrap` for auto-discovery |
| **Modular Terraform** | Reusable modules for VCN, OKE, IAM, Cloudflare DNS |
| **GitOps (FluxCD)** | Declarative cluster state with Kustomize and Helm |
| **Secrets Management** | SOPS+age for Git, HashiCorp Vault for runtime |
| **Service Mesh** | Istio with mTLS and traffic management |
| **Free-Tier Optimized** | ARM nodes within OCI always-free limits |
| **App Templates** | Ready-to-use patterns for common deployments |

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/LarsenClose/k8s-oci-foundation.git
cd k8s-oci-foundation

# 2. Run OCI discovery (requires oci-tf-bootstrap)
task discover

# 3. Copy and configure
cp .envrc.example .envrc
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
# Edit with your values

# 4. Deploy infrastructure
task init
task validate:prerequisites
task plan ENV=dev
task apply ENV=dev

# 5. Bootstrap GitOps
task bootstrap:flux
task bootstrap:genesis  # Optional: envelope-encrypted secrets
```

## Architecture

```
k8s-oci-foundation/
├── modules/                    # Terraform modules
│   ├── oci-network/            # VCN, subnets, gateways
│   ├── oci-oke/                # OKE cluster + ARM node pools
│   ├── oci-iam/                # Dynamic groups + policies
│   ├── cloudflare-zone/        # DNS zone management
│   └── cloudflare-records/     # DNS records (generic)
│
├── environments/               # Per-environment configs
│   └── dev/
│
├── gitops/                     # FluxCD manifests
│   ├── clusters/oci-prod/      # Cluster entry point
│   ├── infrastructure/         # Platform controllers
│   │   ├── controllers/        # cert-manager, Istio, Vault, nginx
│   │   └── configs/            # Gateway, ClusterIssuer
│   └── apps/                   # Application deployments
│       └── _templates/         # Reusable patterns
│
├── tests/                      # OpenTofu tests
└── docs/                       # Documentation
```

## Deployment Phases

| Phase | Description | Command |
|-------|-------------|---------|
| 0 | OCI Discovery | `task discover` |
| 1 | Infrastructure | `task apply ENV=dev` |
| 2 | GitOps Bootstrap | `task bootstrap:flux` |
| 3 | Controllers | Automatic via FluxCD |
| 4 | Vault Init | `task vault:init` |
| 5 | Applications | Deploy via GitOps |

## Extending with Applications

Use the provided templates to deploy your applications:

```bash
# Copy a template
cp -r gitops/apps/_templates/helm-app gitops/apps/my-app

# Configure your HelmRelease
edit gitops/apps/my-app/release.yaml

# Add to kustomization
echo "  - my-app" >> gitops/apps/kustomization.yaml

# Commit and push - FluxCD handles the rest
git add . && git commit -m "feat: add my-app" && git push
```

## Application Overlays

This foundation is designed to be extended. Example overlays:

- **[disentangle-network/deploy](https://github.com/disentangle-network/deploy)** - Disentangle Protocol deployment
- Custom applications via `gitops/apps/`

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| OpenTofu | >= 1.6.0 | Infrastructure as Code |
| kubectl | >= 1.28 | Kubernetes CLI |
| flux | >= 2.0 | GitOps CLI |
| age | >= 1.0 | Encryption |
| sops | >= 3.8 | Secret management |
| task | >= 3.0 | Task runner |
| OCI CLI | >= 3.0 | Oracle Cloud CLI |

## Configuration

### Environment Variables

```bash
# Required
export CLOUDFLARE_API_TOKEN="your-token"
export GITHUB_TOKEN="ghp_your-token"

# Optional (for genesis integration)
export SOPS_AGE_KEY_FILE="$PWD/age.key"
```

### Cluster Settings

Key variables in `cluster-settings.yaml`:

```yaml
CLUSTER_NAME: "my-cluster"
CLUSTER_DOMAIN: "example.com"
CLUSTER_EMAIL: "admin@example.com"
STORAGE_CLASS: "oci-bv"
```

## Component Versions

| Component | Version |
|-----------|---------|
| Kubernetes | 1.31.x |
| cert-manager | 1.16.2 |
| Istio | 1.24.0 |
| Vault | 1.17.6 |
| ingress-nginx | 4.11.3 |
| external-dns | 1.14.5 |

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - Detailed design and component interactions
- [Prerequisites](docs/PREREQUISITES.md) - Tool installation and setup
- [Security](SECURITY.md) - Security policy and considerations

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

Apache 2.0 - See [LICENSE](LICENSE) for details.

## Related Projects

- [oci-tf-bootstrap](https://github.com/LarsenClose/oci-tf-bootstrap) - OCI resource discovery
- [genesis](https://github.com/LarsenClose/genesis) - GitOps secrets bootstrap
- [disentangle-network/deploy](https://github.com/disentangle-network/deploy) - Disentangle Protocol deployment
- [yubikey-init](https://github.com/LarsenClose/yubikey-init) - Hardware key provisioning
