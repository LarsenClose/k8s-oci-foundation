# Contributing to k8s-oci-foundation

Thank you for your interest in contributing to k8s-oci-foundation. This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. Search existing issues to avoid duplicates
2. Use the issue templates when available
3. Include relevant details:
   - OpenTofu/Terraform version
   - OCI region and environment
   - Error messages and logs
   - Steps to reproduce

### Security Vulnerabilities

**Do not report security vulnerabilities through public GitHub issues.** See [SECURITY.md](SECURITY.md) for responsible disclosure instructions.

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the code style** guidelines below
3. **Add tests** for new functionality
4. **Update documentation** as needed
5. **Ensure all checks pass** before submitting

#### Branch Naming

Use descriptive branch names:

- `feature/add-multi-region-support`
- `fix/vcn-security-list-rules`
- `docs/update-prerequisites`
- `refactor/module-structure`

#### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(oke): add support for node pool autoscaling

fix(cloudflare): correct DNS record TTL validation

docs(readme): add troubleshooting section for SOPS errors
```

### Code Style

#### Terraform/OpenTofu

- Use `terraform fmt` or `tofu fmt` before committing
- Follow [HashiCorp's style conventions](https://developer.hashicorp.com/terraform/language/syntax/style)
- Use meaningful variable and resource names
- Include descriptions for all variables and outputs
- Group related resources with comments

```hcl
# Network resources
resource "oci_core_vcn" "main" {
  # ...
}

# Compute resources
resource "oci_containerengine_cluster" "oke" {
  # ...
}
```

#### YAML (GitOps manifests)

- Use 2-space indentation
- Include comments for non-obvious configurations
- Use variable substitution (`${VARIABLE}`) instead of hardcoded values

#### Taskfile

- Include descriptions for all tasks
- Use `deps` for task dependencies
- Group related tasks with namespaces

### Testing

#### Running Tests

```bash
# Validate Terraform/OpenTofu syntax
task validate:tofu

# Run module tests (requires mock providers)
tofu test

# Validate prerequisites
task validate:prerequisites
```

#### Writing Tests

- Place test files in the module directory as `*.tftest.hcl`
- Use mock providers for unit tests
- Test both success and failure conditions
- Include integration tests for module interactions

Example test structure:
```hcl
mock_provider "oci" {}

run "vcn_creates_successfully" {
  command = plan

  assert {
    condition     = oci_core_vcn.main.cidr_blocks[0] == "10.0.0.0/16"
    error_message = "VCN CIDR block should be 10.0.0.0/16"
  }
}
```

### Documentation

- Update README.md for user-facing changes
- Update docs/ARCHITECTURE.md for structural changes
- Add inline comments for complex logic
- Keep examples up to date

### No Secrets Policy

**Critical**: This repository is designed as a public template.

- Never commit secrets, tokens, or credentials
- Use `.example` suffixes for template files
- Use SOPS encryption for any secrets in GitOps manifests
- Verify with `git diff --cached` before committing

Files that should never contain real values:
- `*.tfvars` (use `*.tfvars.example`)
- `cluster-settings.yaml` (use `cluster-settings.yaml.example`)
- `.envrc` (use `.envrc.example`)

## Development Setup

### Prerequisites

See [docs/PREREQUISITES.md](docs/PREREQUISITES.md) for required tools.

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/k8s-oci-foundation.git
cd k8s-oci-foundation

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/k8s-oci-foundation.git

# Create example configs
cp .envrc.example .envrc
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars

# Initialize
task init

# Run validation
task validate:prerequisites
task validate:tofu
```

### Keeping Your Fork Updated

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

## Review Process

1. All PRs require at least one approval
2. CI checks must pass
3. No merge conflicts with `main`
4. Documentation updated if applicable

### What We Look For

- Code follows project conventions
- Changes are well-tested
- No secrets or sensitive data
- Clear commit messages
- Documentation is updated

## Getting Help

- Open a [GitHub Discussion](../../discussions) for questions
- Check existing [Issues](../../issues) for known problems
- Review [docs/](docs/) for detailed documentation

## Recognition

Contributors are recognized in release notes. Significant contributions may be acknowledged in the README.

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
