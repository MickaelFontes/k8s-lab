resource "google_service_account" "node_sa" {
  account_id   = "${var.cluster_name}-node-sa"
  display_name = "Service Account for GKE nodes"
}


resource "google_project_iam_member" "node_sa_iam_member" {
  project = var.project_id
  count   = length(var.iam_roles_list)
  role    = var.iam_roles_list[count.index]
  member  = "serviceAccount:${google_service_account.node_sa.email}"
}
