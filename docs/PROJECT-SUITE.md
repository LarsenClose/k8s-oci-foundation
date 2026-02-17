# OCI Infrastructure Project Suite

This document describes the relationships between the projects in this infrastructure suite.

## Overview

```
                        ┌─────────────────────┐
                        │    yubikey-init     │
                        │  (Hardware Identity)│
                        └──────────┬──────────┘
                                   │ GPG keys for signing
                                   ▼
┌─────────────────────┐    ┌─────────────────────┐
│  oci-tf-bootstrap   │    │       genesis       │
│  (OCI Discovery)    │    │  (Secrets Bootstrap)│
└──────────┬──────────┘    └──────────┬──────────┘
           │                          │
           │ generates                │ provides
           │ Terraform base           │ envelope-encrypted
           ▼                          │ age key
┌─────────────────────────────────────┴─────────────────────┐
│                    k8s-oci-foundation                      │
│  (Generic Kubernetes Infrastructure on OCI)                │
│                                                            │
│  VCN │ OKE │ IAM │ FluxCD │ Istio │ Vault │ cert-manager  │
└─────────────────────────────┬─────────────────────────────┘
                              │ extends
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  disentangle-network/deploy                   │
│  (Disentangle Protocol Deployment)                            │
│                                                              │
│  Helm Chart │ FluxCD Overlays │ StatefulSet │ P2P │ PoW      │
└─────────────────────────────────────────────────────────────┘
```

## Projects

### 1. oci-tf-bootstrap

**Purpose**: Auto-discover OCI tenancy resources and generate ready-to-use Terraform configurations.

**Repository**: [github.com/LarsenClose/oci-tf-bootstrap](https://github.com/LarsenClose/oci-tf-bootstrap)

**Key Features**:
- Discovers tenancy OCIDs, compartments, availability domains
- Filters for Always Free tier resources
- Generates provider.tf, locals.tf, data.tf
- Single Go binary, no dependencies

**Output**: Terraform files consumed by k8s-oci-foundation

**Usage**:
```bash
oci-tf-bootstrap --always-free --output=./terraform-base
```

---

### 2. genesis

**Purpose**: Solve the "chicken-and-egg" problem in GitOps secrets management using envelope encryption with cloud KMS.

**Repository**: [github.com/LarsenClose/genesis](https://github.com/LarsenClose/genesis)

**Key Features**:
- Envelope encryption (age key encrypted with KMS)
- Identity-based decryption (OIDC, IRSA, Workload Identity)
- Kubernetes operator for automatic secret injection
- Supports AWS KMS, GCP KMS, Azure Key Vault, YubiKey, TPM

**Output**: Encrypted bootstrap configuration safe to commit to Git

**Usage**:
```bash
genesis init --provider=aws --key-id=alias/my-key
genesis seal --input=secrets.yaml
kubectl apply -f genesis-bootstrap.yaml
```

---

### 3. k8s-oci-foundation

**Purpose**: Generic, production-grade Kubernetes infrastructure on Oracle Cloud Infrastructure.

**Repository**: [github.com/LarsenClose/k8s-oci-foundation](https://github.com/LarsenClose/k8s-oci-foundation)

**Key Features**:
- Modular Terraform (VCN, OKE, IAM, Cloudflare DNS)
- FluxCD GitOps with SOPS encryption
- Istio service mesh (HTTP/HTTPS only)
- HashiCorp Vault for runtime secrets
- cert-manager with Let's Encrypt
- App deployment templates

**Consumes**:
- oci-tf-bootstrap: Terraform base configuration
- genesis: Secrets bootstrap (optional)

**Output**: Running Kubernetes cluster with GitOps

**Usage**:
```bash
task discover        # Uses oci-tf-bootstrap
task apply ENV=dev
task bootstrap:flux
task bootstrap:genesis  # Optional
```

---

### 4. disentangle-network/deploy

**Purpose**: Disentangle Protocol blockchain network deployment, extending k8s-oci-foundation.

**Repository**: [github.com/disentangle-network/deploy](https://github.com/disentangle-network/deploy)

**Key Features**:
- Helm chart for Disentangle node deployment
- FluxCD GitOps overlays (dev/staging/production)
- StatefulSet-based nodes with PVC for persistent chain data
- P2P discovery for node communication
- Proof-of-Work consensus engine
- NetworkPolicy and PodDisruptionBudget for production resilience

**Deploys**: disentangle-node containers via StatefulSet with PVC, NetworkPolicy, PDB

**Requires**: k8s-oci-foundation deployed first

**Usage**:
```bash
# After foundation is deployed
cd deploy
task deploy ENV=dev
```

---

### 5. yubikey-init

**Purpose**: Secure initialization of YubiKey hardware security keys for GPG/SSH authentication.

**Repository**: [github.com/LarsenClose/yubikey-init](https://github.com/LarsenClose/yubikey-init)

**Key Features**:
- GPG master key generation (ED25519 or RSA-4096)
- Subkey creation for signing, encryption, authentication
- YubiKey provisioning with secure PIN/PUK
- Backup creation with encrypted storage
- SSH integration via GPG agent

**Integration**: Provides hardware-backed identity for signing commits and potentially for genesis master key

**Usage**:
```bash
yubikey-init init
yubikey-init provision
yubikey-init export-ssh
```

---

## Deployment Flow

### Full Stack Deployment

```bash
# 1. (Optional) Set up hardware identity
cd yubikey-init
yubikey-init init && yubikey-init provision

# 2. Discover OCI resources
cd ../k8s-oci-foundation
oci-tf-bootstrap --always-free --output=./generated/terraform-base

# 3. Configure and deploy infrastructure
cp .envrc.example .envrc && source .envrc
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
# Edit with your values

task init
task apply ENV=dev
task bootstrap:flux

# 4. (Optional) Bootstrap secrets with genesis
genesis init --provider=aws
kubectl apply -f genesis-bootstrap.yaml

# 5. (Optional) Deploy Disentangle Protocol
cd ../deploy
task deploy ENV=dev
```

### Minimal Deployment (No Disentangle)

```bash
cd k8s-oci-foundation
task discover
task apply ENV=dev
task bootstrap:flux
# Done - deploy your apps via gitops/apps/
```

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Cloud | Oracle Cloud Infrastructure (OCI) |
| IaC | OpenTofu / Terraform |
| Container Orchestration | OKE (Kubernetes 1.31) |
| GitOps | FluxCD |
| Service Mesh | Istio |
| Secrets (Git) | SOPS + age |
| Secrets (Runtime) | HashiCorp Vault |
| Certificates | cert-manager + Let's Encrypt |
| DNS | Cloudflare |
| Blockchain | Disentangle Protocol |
| Hardware Security | YubiKey (PIV) |

---

## Security Model

```
┌─────────────────────────────────────────────────────────────┐
│                    Trust Hierarchy                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  YubiKey (Hardware Root)                                    │
│      │                                                      │
│      ├── GPG Master Key (offline backup)                    │
│      │       │                                              │
│      │       └── Signing Subkey (commits, releases)         │
│      │                                                      │
│      └── genesis Master Key (optional)                      │
│              │                                              │
│              └── Cloud KMS Envelope                         │
│                      │                                      │
│                      └── age Key (SOPS decryption)          │
│                              │                              │
│                              └── Flux System Secrets        │
│                                      │                      │
│                                      └── Vault Bootstrap    │
│                                              │              │
│                                              └── App Secrets│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## License

All projects in this suite are licensed under Apache 2.0.

## Contributing

Each project has its own CONTRIBUTING.md. General principles:
- No hardcoded secrets
- Tests for all modules
- Documentation for all features
- Semantic versioning
