module "vault" {
  source        = "git::https://github.com/hashicorp/vault-guides//operations/provision-vault/quick-start/terraform-aws"
  name          = "${var.prefix}"
  vault_tags    = "${var.tags}"
  network_tags  = "${var.tags}"
  consul_public = "${var.consul_is_public}"
  vault_public  = "${var.vault_is_public}"
  consul_servers = 1
  vault_servers  = 1
}

output "ssh_private_key" {
  value = "${module.vault.private_key_pem}"
}

output "vault_server_address_public" {
  value = "${module.vault.vault_lb_dns}"
}

output "consul_server_address_public" {
  value = "${module.vault.consul_lb_dns}"
}
