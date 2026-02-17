# Prerequisites

## Required Tools

| Tool | Minimum Version | Purpose |
|------|-----------------|---------|
| [OpenTofu](https://opentofu.org/) | >= 1.6.0 | Infrastructure as Code (Terraform-compatible) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | >= 1.28 | Kubernetes CLI |
| [Flux CLI](https://fluxcd.io/flux/installation/) | >= 2.0 | GitOps toolkit |
| [age](https://github.com/FiloSottile/age) | >= 1.0 | File encryption for SOPS |
| [SOPS](https://github.com/getsops/sops) | >= 3.8 | Secret management in Git |
| [Task](https://taskfile.dev/) | >= 3.0 | Task runner |
| [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) | >= 3.0 | Oracle Cloud CLI |

## Optional Tools

| Tool | Purpose |
|------|---------|
| [direnv](https://direnv.net/) | Automatic environment variable loading from `.envrc` |
| [terraform-docs](https://terraform-docs.io/) | Module documentation generation |
| [tflint](https://github.com/terraform-linters/tflint) | Terraform linter |
| [kubeconform](https://github.com/yannh/kubeconform) | Kubernetes manifest validation |
| [yamllint](https://github.com/adrienverdelhan/yamllint) | YAML linting |

## Installation

### macOS (Homebrew)

```bash
# Core tools
brew install opentofu
brew install kubectl
brew install fluxcd/tap/flux
brew install age
brew install sops
brew install go-task
brew install oci-cli

# Optional
brew install direnv
brew install terraform-docs
brew install tflint
brew install kubeconform
brew install yamllint
```

### Linux

```bash
# OpenTofu
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb  # or --install-method rpm

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# age
sudo apt install age  # Debian/Ubuntu
# or
sudo dnf install age  # Fedora

# SOPS
curl -LO https://github.com/getsops/sops/releases/latest/download/sops-v3.9.0.linux.arm64
chmod +x sops-* && sudo mv sops-* /usr/local/bin/sops

# Task
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

## OCI Account Setup

1. **Create an OCI account** at [cloud.oracle.com](https://cloud.oracle.com). The Always Free tier provides sufficient resources for this project.

2. **Configure the OCI CLI**:
   ```bash
   oci setup config
   ```
   This creates `~/.oci/config` with your tenancy OCID, user OCID, region, and API key.

3. **Note your tenancy details** (used in `terraform.tfvars`):
   - Tenancy OCID: `oci iam tenancy get --query 'data.id' --raw-output`
   - Compartment OCID: `oci iam compartment list --query 'data[0].id' --raw-output`
   - Region: Check `~/.oci/config`

   Alternatively, use [oci-tf-bootstrap](https://github.com/LarsenClose/oci-tf-bootstrap) to auto-discover these values:
   ```bash
   task discover
   ```

## Cloudflare Account Setup

1. **Create a Cloudflare account** at [dash.cloudflare.com](https://dash.cloudflare.com).

2. **Add your domain** to Cloudflare and update your registrar's nameservers.

3. **Create an API token** with the following permissions:
   - Zone: DNS: Edit
   - Zone: Zone: Read
   - Zone: Zone Settings: Edit

4. **Note your account details**:
   - Account ID: Found on the Cloudflare dashboard overview page
   - API Token: Created in step 3

## GitHub Setup

A GitHub personal access token is required for FluxCD bootstrap:

1. Go to [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Create a token with `repo` scope
3. Export as `GITHUB_TOKEN`

## Environment Configuration

Copy the example environment file and fill in your values:

```bash
cp .envrc.example .envrc
```

Required variables:
```bash
export CLOUDFLARE_API_TOKEN="your-cloudflare-api-token"
export GITHUB_TOKEN="ghp_your-github-token"
```

If using direnv, allow the file:
```bash
direnv allow
```

## Validation

Run the prerequisites check to verify your setup:

```bash
task validate:prerequisites
```

This checks for all required tools and validates OCI and Cloudflare connectivity.
