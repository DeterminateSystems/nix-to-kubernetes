variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "k8s_cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
}

variable "k8s_num_nodes" {
  type        = number
  description = "Kubernetes node pool size"
}

variable "k8s_region" {
  type        = string
  description = "DigitalOcean region"
}

variable "k8s_worker_size" {
  type        = string
  description = "Droplet size for Kubernetes node pool"
}

variable "k8s_node_pool_name" {
  type        = string
  description = "Kubernetes node pool name"
}

variable "k8s_version_prefix" {
  type        = string
  description = "The version of Kubernetes to deploy"
}
