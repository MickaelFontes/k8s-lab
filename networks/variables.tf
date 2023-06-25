variable "project_id" {
  type = string
  description = "The project ID to host the network in"
  default = "my-project"
}

variable "network_name" {
  type = string
  description = "The network (and subnetwork) main name"
  default = "cluster-name"
}

variable "region" {
  type = string
  description = "The region to use"
  default = "us-east1"
}

variable "authorized_ipv4_cidr_blocks" {
  type = map(string)
  description = "The CIDR blocks where HTTPS access is allowed from"
  default = null
}
