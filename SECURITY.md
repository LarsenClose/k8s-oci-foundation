# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | Yes                |
| < 1.0   | No                 |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in k8s-oci-foundation, please report it responsibly.

### How to Report

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisories** (Preferred)
   - Go to the [Security tab](../../security/advisories) of this repository
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send details to LarsenClose@pm.me

3. **Private Disclosure**
   - If GitHub Security Advisories are not available, contact the maintainers directly through the methods listed in the repository

### What to Include

Please include the following information:

- Type of vulnerability (e.g., credential exposure, privilege escalation, injection)
- Location of the affected code (file path, line numbers if applicable)
- Step-by-step instructions to reproduce
- Potential impact of the vulnerability
- Any suggested fixes or mitigations

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution Target**: Within 30 days for critical issues

### What to Expect

1. We will acknowledge receipt of your report
2. We will investigate and validate the issue
3. We will work on a fix and coordinate disclosure timing with you
4. We will credit you in the security advisory (unless you prefer anonymity)

## Security Considerations

### Secrets Management

This project is designed with security as a core principle:

- **No hardcoded secrets**: All sensitive values use SOPS encryption or external secret stores
- **Template files**: Configuration examples use `.example` suffixes
- **Vault integration**: Runtime secrets are injected via HashiCorp Vault
- **Git hygiene**: `.gitignore` excludes all sensitive files

### Files That Must Never Contain Real Secrets

| File Pattern | Purpose | Should Contain |
|--------------|---------|----------------|
| `*.tfvars` | Terraform variables | Placeholder OCIDs |
| `cluster-settings.yaml` | FluxCD variables | Example domains |
| `.envrc` | Shell environment | No tokens |
| `*.sops.yaml` (unencrypted) | Secrets | Must be encrypted |

### Verifying No Secrets Are Committed

```bash
# Check for common secret patterns
git log -p | grep -iE "(password|secret|token|key|credential)" | head -20

# Verify SOPS files are encrypted
for f in $(find . -name "*.sops.yaml"); do
  if ! grep -q "sops:" "$f"; then
    echo "WARNING: $f may not be encrypted"
  fi
done
```

### Infrastructure Security

When deploying this infrastructure:

1. **IAM Policies**: Use least-privilege principles; the provided policies are scoped to compartments
2. **Network Security**: Private subnets for workloads, public only for load balancers
3. **TLS Everywhere**: cert-manager with Let's Encrypt for all ingress
4. **Service Mesh**: Istio provides mTLS between services
5. **Vault Unsealing**: Store unseal keys securely offline; never commit `.vault-init.json`

### Known Security Considerations

| Component | Consideration | Mitigation |
|-----------|---------------|------------|
| Vault | File backend not HA | Use Raft backend for production |
| OKE | Public API endpoint | Use private endpoint + bastion for production |
| Disentangle nodes | Default P2P discovery | Configure static peers for production |
| SOPS | Age key in project | Store age key in secure location |

### Dependency Security

- Terraform providers are version-pinned
- Helm charts use specific versions
- Container images use digest-pinned references where possible

To check for vulnerabilities:

```bash
# Scan Terraform providers
terraform providers lock -platform=linux_amd64

# Check Helm chart versions
helm search repo hashicorp/vault --versions
```

## Security Best Practices for Users

1. **Rotate credentials regularly**
   - OCI API keys
   - Cloudflare API tokens
   - GitHub tokens

2. **Use separate environments**
   - Different OCI compartments for dev/staging/prod
   - Separate Vault instances per environment

3. **Enable audit logging**
   - OCI Audit service
   - Vault audit backend
   - Kubernetes audit logs

4. **Monitor for drift**
   - Use `terraform plan` regularly
   - Enable Flux drift detection

## Security Updates

Security updates will be released as patch versions. Subscribe to repository releases to be notified.

## Acknowledgments

We thank the following individuals for responsibly disclosing security issues:

*No security issues have been reported yet.*
