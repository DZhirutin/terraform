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
  tags = ["myssh"]
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
  tags = ["myssh","mytomcat"]
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
//Create firewall rule ssh
resource "google_compute_firewall" "myssh" {
  name    = "myssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
    
  }

  source_tags = ["myssh"]
  source_ranges = ["149.62.52.67/32"]
}
//Create firewall rule 8080 tomcat
resource "google_compute_firewall" "mytomcat" {
  name    = "mytomcat"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080","80","443"]
    
  }

  source_tags = ["mytomcat"]
  source_ranges = ["0.0.0.0/0"]
}
//Provision the server using remote-exec Prod
resource "null_resource" "prod_provisioner" {
  triggers = {
    public_ip = google_compute_instance.Prod.network_interface.0.access_config.0.nat_ip
  }

  connection {
    type  = "ssh"
    host  = google_compute_instance.Prod.network_interface.0.access_config.0.nat_ip
    user  = "elliot"
    port  = 22
    agent = true
  }
  // copy our example script to the server
  provisioner "file" {
    source      = "prod.sh"
    destination = "/tmp/prod.sh"
  }
// change permissions
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/prod.sh",
       "/tmp/prod.sh",
    ]
  }
}

//Provision the server using remote-exec Build
resource "null_resource" "build_provisioner" {
  triggers = {
    public_ip = google_compute_instance.Build.network_interface.0.access_config.0.nat_ip
  }

  connection {
    type  = "ssh"
    host  = google_compute_instance.Build.network_interface.0.access_config.0.nat_ip
    user  = "elliot"
    port  = 22
    agent = true
  }
  // copy our example script to the server
  provisioner "file" {
    source      = "build.sh"
    destination = "/tmp/build.sh"
  }
// change permissions
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/build.sh",
       "/tmp/build.sh",
    ]
  }


//Copy file from build to prod
provisioner "local-exec" {
    //command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.example_public.public_ip}:/tmp/public-ip public-ip"
    command = "rsync -zarvh /tmp/boxfuse-sample-java-war-hello/target/hello-1.0.war elliot@google_compute_instance.Prod.network_interface.0.access_config.0.nat_ip:/var/lib/tomcat9/webapps/"
  }
}



output "Public_IP_address-Build" {
  value = google_compute_instance.Build.network_interface.0.access_config.0.nat_ip
}

output "Public_IP_address-Prod" {
  value = google_compute_instance.Prod.network_interface.0.access_config.0.nat_ip
}