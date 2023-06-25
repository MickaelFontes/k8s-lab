resource "google_container_cluster" "app_cluster" {
  name     = var.cluster_name
  location = var.region
  provider = google-beta // for protect_config block

  cluster_autoscaling {
    enabled = false
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  network    = var.network_name
  subnetwork = var.subnet_name

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  // Restrict external access to control plane
  master_authorized_networks_config {
  dynamic "cidr_blocks" {
    for_each = var.authorized_ipv4_cidr_blocks
    content {
      cidr_block = cidr_blocks.key
      display_name = cidr_blocks.value
    }
  }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  release_channel {
    channel = "STABLE"
  }

  addons_config {
    // TODO: Enable network policy (Calico)
    network_policy_config {
      disabled = false
    }
  }

  /* Enable network policy configurations (like Calico).
  For some reason this has to be in here twice. */
  network_policy {
    enabled = "true"
  }

  // service_external_ips_config enabled by default

  // Optionals (already set by default)
  enable_shielded_nodes = true
  enable_legacy_abac = false

  // only in google-beta provider
  protect_config {
    workload_config {
      audit_mode = "BASIC" # DISABLED or BASIC
    }
    workload_vulnerability_mode = "BASIC" # DISABLED or BASIC
  }
}

resource "google_container_node_pool" "app_cluster_linux_node_pool" {
  name           = "${google_container_cluster.app_cluster.name}--linux-node-pool"
  location       = google_container_cluster.app_cluster.location
  node_locations = var.node_zones
  cluster        = google_container_cluster.app_cluster.name
  node_count     = 0

  max_pods_per_node = 100

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-standard-4"
    preemptible  = true # For lower cost
    disk_size_gb = 40

    service_account = var.service_account
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      cluster = google_container_cluster.app_cluster.name
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    // Enable workload identity on this node pool.
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy.
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint.
      disable-legacy-endpoints = "true"
    }
  }
}
