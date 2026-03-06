# OKE Deployment Workflow

End-to-end guide for provisioning an OKE (Oracle Kubernetes Engine) cluster on OCI using OpenTofu and deploying workloads with Helm.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| OCI CLI | >= 3.0 | `brew install oci-cli` or [docs](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) |
| OpenTofu | >= 1.6.0 | `brew install opentofu` or [opentofu.org](https://opentofu.org/docs/intro/install/) |
| kubectl | >= 1.28 | `brew install kubectl` |
| Helm | >= 3.x | `brew install helm` |

### OCI Credentials

You need the following identifiers from your OCI tenancy. Run `oci setup config` to configure them, or export as environment variables:

- **Tenancy OCID** -- `ocid1.tenancy.oc1..xxxx`
- **Compartment OCID** -- `ocid1.compartment.oc1..xxxx`
- **User OCID** -- `ocid1.user.oc1..xxxx`
- **Fingerprint** -- API key fingerprint registered in OCI console
- **Private key path** -- Path to the PEM key associated with the fingerprint

### Optional

- **Cloudflare API token** -- Required only if using Cloudflare DNS integration. Create at [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens) with Zone:DNS:Edit and Zone:Zone:Read permissions.

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/LarsenClose/k8s-oci-foundation.git
   cd k8s-oci-foundation
   ```

2. **Configure variables**

   ```bash
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
   ```

   Edit `environments/dev/terraform.tfvars` and fill in your OCI tenancy OCID, compartment OCID, region, and other values. See the example file for descriptions of each variable.

3. **Initialize OpenTofu**

   ```bash
   cd environments/dev
   tofu init
   ```

4. **Review the plan**

   ```bash
   tofu plan -out=tfplan
   ```

   Inspect the output to confirm the resources that will be created (VCN, subnets, OKE cluster, node pools, IAM policies, Cloudflare records).

5. **Apply**

   ```bash
   tofu apply tfplan
   ```

   OKE cluster provisioning typically takes ~15 minutes. Node pool creation runs in parallel with the cluster and nodes may take an additional 5--10 minutes to register.

6. **Verify the cluster**

   The kubeconfig is written automatically to the repo root (`../../kubeconfig` relative to `environments/dev/`).

   ```bash
   export KUBECONFIG="$(git rev-parse --show-toplevel)/kubeconfig"
   kubectl get nodes
   ```

   You should see 2 ARM nodes in `Ready` state.

## Deploying Workloads

### Disentangle Helm Chart

The [disentangle-network/deploy](https://github.com/disentangle-network/deploy) chart can be installed directly against the cluster:

```bash
export KUBECONFIG="$(git rev-parse --show-toplevel)/kubeconfig"

helm install disentangle <path-to-deploy-chart> \
  --namespace disentangle --create-namespace \
  --set nodes.count=3 \
  --set resources.limits.cpu=250m \
  --set resources.limits.memory=256Mi \
  --set resources.requests.cpu=50m \
  --set resources.requests.memory=64Mi
```

Replace `<path-to-deploy-chart>` with the local path to the Helm chart directory (e.g., `../deploy/charts/disentangle`).

### GitOps (FluxCD)

For declarative management, bootstrap FluxCD and add your application to `gitops/apps/`. See the README for details on the GitOps workflow and app templates.

## Always Free Tier Constraints

The default configuration targets OCI's Always Free ARM tier.

| Resource | Limit | Current Usage |
|----------|-------|---------------|
| ARM OCPUs | 4 total | 4 (2 nodes x 2 OCPUs) |
| ARM Memory | 24 GB total | 24 GB (2 nodes x 12 GB) |
| Block Volume | 200 GB total | 150 GB (3 x 50Gi PVCs) |

Key limitations:

- **OCI minimum PV size is 50Gi.** The `oci-bv` storage class provisions OCI Block Volumes, which have a 50Gi floor regardless of what the PVC requests. A chart requesting 1Gi will still consume 50Gi of quota.
- **Cannot exceed 3 PVCs** without breaching the 200GB block volume quota (3 x 50Gi = 150Gi; a 4th would require 200Gi total, hitting the ceiling).
- **No room to add nodes.** The 4 OCPU / 24GB memory budget is fully allocated across 2 nodes.

Monitor block volume usage:

```bash
oci limits value list \
  --service-name blockstorage \
  --compartment-id <compartment-ocid> \
  --availability-domain <ad-name> \
  --query "data[?name=='total-storage-gb'].value"
```

## Troubleshooting

### Security list rules

OKE requires specific ingress rules on the private subnet security list for node-to-control-plane communication (TCP ports 6443, 10250, 12250). If nodes fail to register or `kubectl` commands hang, verify these rules exist in the network module. Fixed in commit `fd7bc4f`.

### Image lookup failures

OKE node pool images must match the exact Kubernetes version. The `main.tf` in `environments/dev/` uses a dynamic lookup (`local.oke_arm_image_id`) that filters OKE-compatible aarch64 images by version string. If `tofu plan` fails with an empty image list, confirm that `kubernetes_version` in your tfvars matches a version available in your region. Fixed in commits `5632c35` and `48eb176`.

### Node registration delays

OKE nodes can take 5--10 minutes to register after the node pool reports as ACTIVE. This is normal. Monitor with:

```bash
kubectl get nodes --watch
```

### PVC sizing

Charts may request small volumes (e.g., 1Gi) but OCI provisions 50Gi minimum. The PVC will show as `Bound` with the requested size, but the underlying block volume is 50Gi. This is expected behavior, not an error.

### State persistence warnings

The disentangle-node binary may log periodic save warnings (permission errors on state files). This is a known application-level issue, not an infrastructure problem.

## Teardown

Destroy all provisioned resources:

```bash
cd environments/dev
tofu destroy
```

This destroys the OKE cluster, node pools, VCN, IAM policies, Cloudflare DNS records, and all associated data. Block volumes backing PVCs are deleted. This action is irreversible.
