terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.74.0"
    }
  }
}

provider "google" {
  project     = "schooldevops"
  region      = "europe-west1"
  zone        = "europe-west1-b"
}

//Create instance build
resource "google_compute_instance" "Build" {
  name         = "build"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210623"
    }
  }
  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
}

//Create instance prod
resource "google_compute_instance" "Prod" {
  name         = "prod"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210623"
    }
  }
  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
}

output "Public_IP_address-Build" {
  value = google_compute_instance.Build.network_interface.0.access_config.0.nat_ip
}

output "Public_IP_address-Prod" {
  value = google_compute_instance.Prod.network_interface.0.access_config.0.nat_ip
}