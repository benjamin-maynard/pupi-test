locals {
  private_google_access_ips = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11"
  ]
}

// Create a private zone for googleapis.com which we will use to re-map
// Google API's to the Private Google Acces range
resource "google_dns_managed_zone" "googleapis-com" {

  name        = "googleapis-com"
  dns_name    = "googleapis.com."
  description = "Google API's Private Zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.pupi_vpc.id
    }
  }
  project = var.project_id
}

// Create a private.googleapis.com A record in the googleapis.com Zone.
// with values from the 199.36.153.8/30 range
// https://cloud.google.com/vpc/docs/configure-private-google-access#config-domain
resource "google_dns_record_set" "private-googleapis-com" {
  name         = "private.googleapis.com."
  type         = "A"
  rrdatas      = local.private_google_access_ips
  managed_zone = google_dns_managed_zone.googleapis-com.name
  project      = var.project_id
}

// Create a wildcard CNAME record that catches all Google API's requests,
// and maps them to private.googleapis.com IP's via the CNAME
resource "google_dns_record_set" "star-googleapis-com" {
  name = "*.googleapis.com."
  type = "CNAME"
  rrdatas = [
    google_dns_record_set.private-googleapis-com.name
  ]
  managed_zone = google_dns_managed_zone.googleapis-com.name
  project      = var.project_id
}

// There are some additional domains we also need to re-map, not exhaustive
// but all we need for GKE. Create the Zones. Configure wildcards for subdomains
resource "google_dns_managed_zone" "wildcards-pga" {

  // We will create wildcard record for these domains
  for_each = toset([
    "cloudfunctions.net",
    "gcr.io",
    "pkg.dev",
    "pki.goog",
    "run.app"
  ])

  name        = replace(each.key, ".", "-")
  dns_name    = "${each.key}."
  description = "Private Zone for ${each.key}"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.pupi_vpc.id
    }
  }
  project = var.project_id
}


// Create wildcard records
resource "google_dns_record_set" "wildcards-pga" {

  // We will create wildcard record for these domains
  for_each = toset([
    "cloudfunctions.net",
    "gcr.io",
    "pkg.dev",
    "pki.goog",
    "run.app"
  ])


  name = "*.${each.key}."
  type = "CNAME"
  rrdatas = [
    google_dns_record_set.private-googleapis-com.name
  ]
  managed_zone = google_dns_managed_zone.wildcards-pga[each.key].name
  project      = var.project_id

}

// We also need to re-point gcr.io, which cannot use a CNAME due to
// being a naked domain
resource "google_dns_record_set" "naked-pga" {

  // We will create wildcard record for these domains
  for_each = toset([
    "gcr.io",
  ])

  name         = "${each.key}."
  type         = "A"
  rrdatas      = local.private_google_access_ips
  managed_zone = google_dns_managed_zone.wildcards-pga[each.key].name
  project      = var.project_id

}
