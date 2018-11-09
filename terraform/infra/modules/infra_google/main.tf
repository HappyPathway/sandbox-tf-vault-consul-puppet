provider "google" {
  credentials = "${var.gcp_credentials}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

data "template_file" "google_startup_script" {
  template = "${file("${path.module}/../../templates/puppet_agent_bootstrap.sh.tpl")}"

  vars {
    papertrail_token = "${var.papertrail_token}"
    puppet_master_addr = "${var.puppet_master_addr}"
    logic = "${file("${path.module}/../../scripts/puppet_agent_bootstrap.sh")}"
  }
}

resource "google_compute_instance" "gcp_instance" {
  name         = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.gcp_zone}"

  metadata_startup_script = "${data.template_file.google_startup_script.rendered}"

#  tags = "${var.tags}"

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
