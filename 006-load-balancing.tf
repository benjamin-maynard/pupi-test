# Reserve a 30.0.0.0/8 IP for an Internal Load Balancer
resource "google_compute_address" "internal-load-balancer-test" {
  name         = "test-internal-address"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  address      = "30.3.2.22"
  subnetwork   = google_compute_subnetwork.pupi_subnet.id
  project      = var.project_id
}
