// Configure Google Provider
provider "google" {
  region = "us-central1"
}

// Configure Google Beta Provider
provider "google-beta" {
  region = "us-central1"
}

// Specify Required Providers
terraform {
  required_providers {
    google = {
      version = "5.10.0"
    }
    google-beta = {
      version = "5.10.0"
    }
  }
}
