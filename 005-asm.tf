// Enable the ASM Feature
resource "google_gke_hub_feature" "asm" {
  name     = "servicemesh"
  location = "global"
  project = var.project_id
}

// Join the cluster to the Fleet
resource "google_gke_hub_membership" "membership" {
  membership_id = google_container_cluster.pupi_cluster.name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.pupi_cluster.id}"
    }
  }
  project = var.project_id
}

// Enable Managed ASM
resource "google_gke_hub_feature_membership" "asm_feature_member" {
  location   = "global"
  feature    = google_gke_hub_feature.asm.name
  membership = google_gke_hub_membership.membership.membership_id
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
  project = var.project_id
}
