variable "project_id" {
  type = string
  description = "The ID of the project to create resources in"
  default = "my-project"
}

variable "region" {
  type = string
  description = "The region to use"
  default = "us-east1"
}

variable "main_zone" {
  type = string
  description = "The zone to use as primary"
  default = "us-east1-b"
}

variable "cluster_name" {
  type = string
  description = "The name of the cluster (and all linked resources, network, node pool, etc.)"
  default = "k8s-lab-cluster"
}

variable "cluster_node_zones" {
  type = list(string)
  description = "The zones where Kubernetes cluster worker nodes should be located"
  default = ["us-east1-b"]
}

variable "control_plane_authorized_ipv4" {
  type = map(string)
  description = "List of external networks that can access Kubernetes master through HTTPS. Must be specified in CIDR notation."
  default = {
  "1.2.3.4/32": "home"
  }
}

variable "enable_autopilot" {
  type        = bool
  description = "To deploy an autopilot cluster or not"
  default     = false
}
