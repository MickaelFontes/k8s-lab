terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.51.0"
    }
  }
  backend "gcs" {
    bucket = "MANUAL_EDIT_WRITE_YOUR_BUCKET"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

module "gke_iam" {
  source = "./gke_iam"

  project_id     = var.project_id
  cluster_name   = var.cluster_name
  iam_roles_list = ["roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/monitoring.viewer", "roles/stackdriver.resourceMetadata.writer"] # see https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa or roles/container.nodeServiceAccount
}

module "google_networks" {
  source = "./networks"

  project_id   = var.project_id
  network_name = var.cluster_name
  region       = var.region
  authorized_ipv4_cidr_blocks = var.control_plane_authorized_ipv4
}

module "google_kubernetes_cluster" {
  source = "./kubernetes_cluster"
  depends_on = [module.google_networks, module.gke_iam]

  project_id                  = var.project_id
  main_zone                   = var.main_zone
  region                      = var.region
  cluster_name                = var.cluster_name
  node_zones                  = var.cluster_node_zones
  service_account             = module.gke_iam.serviceAccount.email
  network_name                = module.google_networks.network.name
  subnet_name                 = module.google_networks.subnet.name
  master_ipv4_cidr_blocks     = module.google_networks.cluster_master_ip_cidr_ranges
  pods_ipv4_cidr_blocks       = module.google_networks.cluster_pods_ip_cidr_ranges
  services_ipv4_cidr_blocks   = module.google_networks.cluster_services_ip_cidr_ranges
  authorized_ipv4_cidr_blocks = var.control_plane_authorized_ipv4
  enable_autopilot            = var.enable_autopilot
}
