data "template_file" "consul_server_bootstrap_sh" {
  template = "${file("${path.module}/templates/consul_server_bootstrap.sh.tpl")}"

  vars {
    papertrail_token   = "${var.papertrail_token}"
    puppet_master_addr = "${aws_instance.puppet-master.public_dns}"
    logic              = "${file("${path.module}/scripts/consul_server_bootstrap.sh")}"
  }
}

module "consul" {
  source           = "git::https://github.com/nrvale0/consul-guides//operations/provision-consul/dev/terraform-aws?ref=provision-dev-custom-user-data"
  name             = "consul-server-${var.prefix}"
  consul_servers   = 1
  consul_tags      = "${var.tags}"
  network_tags     = "${var.tags}"
  consul_public    = "${var.consul_is_public}"
  consul_version   = "1.3.0"
  consul_user-data = "${data.template_file.consul_server_bootstrap_sh.rendered}"
}

output "consul_ssh_private_key" {
  value = "${module.consul.private_key_pem}"
}

output "consul_server_address_public" {
  value = "${module.consul.consul_lb_dns}"
}
