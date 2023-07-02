output "network" {
  value       = google_compute_network.vpc
  description = "The VPC"
}

output "subnet" {
  value       = google_compute_subnetwork.subnet
  description = "The subnet"
}

output "cluster_master_ip_cidr_ranges" {
  value       = local.cluster_master_ip_cidr_ranges
  description = "The CIDR ranges to use for Kubernetes cluster master"
}

output "cluster_pods_ip_cidr_ranges" {
  value       = local.cluster_pods_ip_cidr_ranges
  description = "The CIDR ranges to use for Kubernetes cluster pods"
}

output "cluster_services_ip_cidr_ranges" {
  value       = local.cluster_services_ip_cidr_ranges
  description = "The CIDR ranges to use for Kubernetes cluster services"
}
