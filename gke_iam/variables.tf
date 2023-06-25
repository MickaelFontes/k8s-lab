variable "project_id" {
  type = string
  description = "The project ID to host the network in"
  default = "my-project"
}

variable "cluster_name" {
  type = string
  description = "The cluster main name"
  default = "cluster-name"
}

variable "iam_roles_list" {
  type = list(string)
  description = "The IAM roles for the node SA"
  default = ["roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/monitoring.viewer", "roles/stackdriver.resourceMetadata.writer"]
}