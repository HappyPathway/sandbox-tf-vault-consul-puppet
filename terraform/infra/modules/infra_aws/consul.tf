data "template_file" "consul_server_bootstrap_sh" {
  template = "${file("${path.module}/templates/consul_server_bootstrap.sh.tpl")}"

  vars {
    papertrail_token = "${var.papertrail_token}"
    logic = "${file("${path.module}/scripts/consul_server_bootstrap.sh")}"
  }
}

module "consul" {
  source        = "git::https://github.com/hashicorp/consul-guides//operations/provision-consul/dev/terraform-aws"
  name          = "${var.prefix}"
  consul_servers = 1 
  consul_tags   = "${var.tags}"
  network_tags  = "${var.tags}"
  consul_public  = "${var.consul_is_public}"

  provisioner "file" "bootstrap_sh" {
    content = "${data.template_file.consul_server_bootstrap_sh.rendered}"
  }

  provisioner "remote-exec" "bootstrap" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh"
    ]
  }
}

output "consul_ssh_private_key" {
  value = "${module.consul.private_key_pem}"
}

output "consul_server_address_public" {
  value = "${module.consul.consul_lb_dns}"
}
