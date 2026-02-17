# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-28

### Added

#### Infrastructure Modules
- `oci-network` - VCN with public/private subnets, gateways, and security lists
- `oci-oke` - OKE cluster with ARM node pools (VM.Standard.A1.Flex)
- `oci-iam` - Dynamic groups and least-privilege IAM policies
- `cloudflare-zone` - DNS zone management with SSL/TLS settings
- `cloudflare-records` - Generic DNS records with custom_records support

#### GitOps Infrastructure
- FluxCD bootstrap with SOPS age key configuration
- cert-manager with Let's Encrypt ClusterIssuer
- Istio service mesh (generic, HTTP/HTTPS only)
- HashiCorp Vault for runtime secrets
- ingress-nginx controller
- external-dns for automatic DNS updates

#### Application Templates
- `_templates/helm-app` - HelmRelease pattern
- `_templates/kustomize-app` - Plain Kubernetes manifests
- `_templates/stateful-app` - StatefulSet with PVC
- `example-app` - Deployable whoami for cluster testing

#### Developer Experience
- Comprehensive Taskfile.yaml automation
- OpenTofu tests for all modules with mock providers
- Example configurations for all sensitive inputs
- GitHub Actions CI workflow

### Security
- Zero hardcoded secrets design
- SOPS+age encryption for GitOps secrets
- Vault integration for runtime secrets
- Network policies for pod isolation
- mTLS via Istio mesh

### Documentation
- README.md with quick start guide
- CONTRIBUTING.md with contribution guidelines
- SECURITY.md with vulnerability reporting policy
- CODE_OF_CONDUCT.md (Contributor Covenant v2.1)

[Unreleased]: https://github.com/LarsenClose/k8s-oci-foundation/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/LarsenClose/k8s-oci-foundation/releases/tag/v1.0.0
