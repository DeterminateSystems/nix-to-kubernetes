// Terraform and provider metadata
terraform {
  required_version = "1.3.2"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.22.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.14.0"
    }
  }
}

// Provider configuration
provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.nix_to_k8s.endpoint
  token = data.digitalocean_kubernetes_cluster.nix_to_k8s.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.nix_to_k8s.kube_config[0].cluster_ca_certificate
  )
}

// Data inputs
data "digitalocean_kubernetes_versions" "current" {
  version_prefix = var.k8s_version_prefix
}

// Outputs
output "k8s_context" {
  value = "do-${var.k8s_region}-${digitalocean_kubernetes_cluster.nix_to_k8s.name}"
}

output "k8s_cluster_name" {
  value = digitalocean_kubernetes_cluster.nix_to_k8s.name
}

// Resources
resource "digitalocean_kubernetes_cluster" "nix_to_k8s" {
  name    = var.k8s_cluster_name
  region  = var.k8s_region
  version = data.digitalocean_kubernetes_versions.current.latest_version

  node_pool {
    name       = var.k8s_node_pool_name
    size       = var.k8s_worker_size
    node_count = var.k8s_num_nodes
  }
}
