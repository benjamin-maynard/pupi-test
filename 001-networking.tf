// Create a VPC
resource "google_compute_network" "pupi_vpc" {
  name                    = "pupi-vpc-test"
  auto_create_subnetworks = false
  project                 = var.project_id
}

// Define main, and secondary Pod and Service ranges using
// 30.0.0.0/8 address range
resource "google_compute_subnetwork" "pupi_subnet" {
  network       = google_compute_network.pupi_vpc.self_link
  name          = "pupi-us-central1"
  ip_cidr_range = "30.3.0.0/22"
  secondary_ip_range = [
    {
      ip_cidr_range = "30.2.0.0/22"
      range_name    = "secondary-pods"
    },
    {
      ip_cidr_range = "30.1.0.0/22"
      range_name    = "secondary-services"
    }
  ]
  private_ip_google_access = true
  project                  = var.project_id
}
