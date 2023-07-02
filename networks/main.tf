locals {
  network_name                   = "kubernetes-${var.network_name}"
  subnet_name                    = "${google_compute_network.vpc.name}--subnet"
  # two ranges to avoid conflict when changing cluster type
  cluster_master_ip_cidr_ranges   = ["10.100.100.0/28", "10.100.101.0/28"]
  cluster_pods_ip_cidr_ranges     = ["10.101.0.0/16", "10.102.0.0/16"]
  cluster_services_ip_cidr_ranges = ["10.103.0.0/16", "10.104.0.0/16"]
}

resource "google_compute_network" "vpc" {
  name                            = local.network_name
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet" {
  name                     = local.subnet_name
  ip_cidr_range            = "10.10.0.0/16"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_route" "egress_internet" {
  name             = "${var.network_name}-egress-internet-public"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_router" "router" {
  name    = "${local.network_name}-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat_router" {
  name                               = "${google_compute_subnetwork.subnet.name}-nat-router"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Deny all other connections.
resource "google_compute_firewall" "gke-deny-all-from-anywhere" {
  name          = "${var.network_name}-gke-deny-all-from-anywhere"
  network       = google_compute_network.vpc.self_link
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  priority      = 1001

  deny {
    protocol = "all"
  }
}

# Allow known connections.
resource "google_compute_firewall" "gke-allow-known" {
  name      = "${var.network_name}-gke-allow-known"
  network   = google_compute_network.vpc.self_link
  direction = "INGRESS"
  project   = var.project_id
  source_ranges = keys(var.authorized_ipv4_cidr_blocks)
  priority = 999

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
}
