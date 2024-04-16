resource "google_container_cluster" "pupi_cluster" {

  name               = "pupi-cluster"
  initial_node_count = 1

  deletion_protection = false

  // If we want to use Service Networking, we can use a Release Channel
  // We do not want to do this if using Private Service Connect as it requires
  // GKE 1.29+
  dynamic "release_channel" {
    for_each = var.use_private_service_connect ? [] : [1]
    content {
      channel = "REGULAR"
    }

  }

  // Only required if we are using PSC
  min_master_version = var.use_private_service_connect ? "1.29.1-gke.1589017" : null

  private_cluster_config {
    enable_private_nodes = true
    // Only required if we are NOT using PSC
    master_ipv4_cidr_block = var.use_private_service_connect ? null : "30.4.0.0/28"

    // Only required if we are using PSC
    private_endpoint_subnetwork = var.use_private_service_connect ? google_compute_subnetwork.pupi_subnet.self_link : null

  }

  network    = google_compute_network.pupi_vpc.self_link
  subnetwork = google_compute_subnetwork.pupi_subnet.self_link

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  resource_labels = {
    mesh_id = "proj-${data.google_project.this.number}"
  }

  # default_snat_status {
  #   disabled = true
  # }

  datapath_provider = "ADVANCED_DATAPATH"

  ip_allocation_policy {
    cluster_secondary_range_name  = "secondary-pods"
    services_secondary_range_name = "secondary-services"
  }

  project = var.project_id

}

