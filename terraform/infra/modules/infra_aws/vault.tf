data "template_file" "vault_server_bootstrap_sh" {
  template = "${file("${path.module}/templates/vault_server_bootstrap.sh.tpl")}"

  vars {
    papertrail_token   = "${var.papertrail_token}"
    puppet_master_addr = "${aws_instance.puppet-master.public_dns}"
    logic              = "${file("${path.module}/scripts/vault_server_bootstrap.sh")}"
  }
}

module "vault" {
  source          = "git::https://github.com/nrvale0/vault-guides//operations/provision-vault/dev/terraform-aws?ref=provision-dev-custom-user-data"
  name            = "${var.prefix}"
  vault_servers   = 1
  vault_tags      = "${var.tags}"
  network_tags    = "${var.tags}"
  vault_public    = "${var.vault_is_public}"
  vault_version   = "0.11.4"
  vault_user-data = "${data.template_file.vault_server_bootstrap_sh.rendered}"
}

output "vault_ssh_private_key" {
  value = "${module.vault.private_key_pem}"
}

output "vault_server_address_public" {
  value = "${module.vault.vault_lb_dns}"
}
