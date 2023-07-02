output "name" {
  value = var.enable_autopilot ? google_container_cluster.autopilot_cluster[0].name : google_container_cluster.app_cluster[0].name
  description = "The Kubernetes cluster name."
}