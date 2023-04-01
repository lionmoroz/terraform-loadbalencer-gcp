terraform {
  required_providers {
    google = {
      version = "4.57.0"
    }
  }
}

provider "google" {
  project     = "${var.project_name}"
  region      = "${var.region}"
}