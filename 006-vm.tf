resource "google_compute_instance" "jump-host" {

  name = "jump-host"

  zone = "${google_compute_subnetwork.pupi_subnet.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  machine_type = "e2-standard-2"

  network_interface {
    subnetwork = google_compute_subnetwork.pupi_subnet.self_link
    access_config {
    }
  }

  project = var.project_id

}
