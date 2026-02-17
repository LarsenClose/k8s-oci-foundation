terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}

provider "oci" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04 Minimal aarch64"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "network" {
  source = "../../modules/oci-network"

  compartment_id      = var.compartment_id
  region              = var.region
  vcn_name            = "${var.environment}-vcn"
  vcn_dns_label       = "${var.environment}vcn"
  vcn_cidrs           = var.vcn_cidrs
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  tags                = local.tags
}

module "oke" {
  source = "../../modules/oci-oke"

  compartment_id       = var.compartment_id
  vcn_id               = module.network.vcn_id
  public_subnet_id     = module.network.public_subnet_id
  private_subnet_id    = module.network.private_subnet_id
  cluster_name         = "${var.environment}-k8s"
  kubernetes_version   = var.kubernetes_version
  availability_domains = data.oci_identity_availability_domains.ads.availability_domains[*].name
  arm_node_pool_count  = var.arm_node_pool_count
  arm_node_pool_size   = var.arm_node_pool_size
  arm_ocpus            = var.arm_ocpus
  arm_memory_gbs       = var.arm_memory_gbs
  arm_image_id         = data.oci_core_images.ubuntu_arm.images[0].id
  ssh_public_key       = var.ssh_public_key
  tags                 = local.tags

  depends_on = [module.network]
}

module "iam" {
  source = "../../modules/oci-iam"

  compartment_id = var.compartment_id
  tenancy_ocid   = var.tenancy_ocid
  cluster_name   = "${var.environment}-k8s"
  tags           = local.tags

  depends_on = [module.oke]
}

module "cloudflare_zone" {
  source = "../../modules/cloudflare-zone"

  domain      = var.cloudflare_domain
  account_id  = var.cloudflare_account_id
  create_zone = var.cloudflare_create_zone
}

module "cloudflare_records" {
  source = "../../modules/cloudflare-records"

  zone_id           = module.cloudflare_zone.zone_id
  cluster_subdomain = var.environment

  # Point to Istio Gateway LoadBalancer IP (set after first deployment)
  load_balancer_ip = var.load_balancer_ip

  # Custom application-specific DNS records
  custom_records = var.custom_dns_records

  depends_on = [module.cloudflare_zone]
}

resource "local_file" "kubeconfig" {
  content         = module.oke.kubeconfig
  filename        = "${path.root}/../../kubeconfig"
  file_permission = "0600"
}

locals {
  tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "tofu"
  })
}
