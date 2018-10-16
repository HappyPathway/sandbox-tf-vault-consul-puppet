variable "gcp_credentials" {
  description = "GCP credentials needed by google provider"
}

variable "gcp_project" {
  description = "GCP project name"
}

variable "gcp_region" {
  description = "GCP region, e.g. us-east1"
  default = "us-east1"
}

variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-a"
  default = "us-east1-b"
}

variable "machine_type" {
  description = "GCP machine type"
  default = "n1-standard-1"
}

variable "instance_name" {
  description = "GCP instance name"
  default = "demo"
}

variable "image" {
  description = "image to build instance from"
  default = "debian-cloud/debian-9"
}

variable "papertrail_token" {}

provider "google" {
  credentials = "${var.gcp_credentials}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

data "template_file" "google_startup_script" {
  template = "${file("${path.module}/../templates/consul_client_bootstrap.sh.tpl")}"

  vars {
    papertrail_token = "${var.papertrail_token}"
    logic = "${file("${path.module}/../scripts/consul_client_bootstrap.sh")}"
  }
}

resource "google_compute_instance" "demo" {
  name         = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.gcp_zone}"

  metadata_startup_script = "${data.template_file.google_startup_script.rendered}"

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }


  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

}

# output "external_ip"{
#   value = "${google_compute_instance.demo.network_interface.0.access_config.0.assigned_nat_ip}"
# }
