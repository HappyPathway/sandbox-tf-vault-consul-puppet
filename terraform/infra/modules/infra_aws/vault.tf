module "vault" {
  source        = "git::https://github.com/hashicorp/vault-guides//operations/provision-vault/dev/terraform-aws"
  name          = "${var.prefix}"
  vault_tags    = "${var.tags}"
  network_tags  = "${var.tags}"
  vault_public  = "${var.vault_is_public}"
}

output "vault_ssh_private_key" {
  value = "${module.vault.private_key_pem}"
}

output "vault_server_address_public" {
  value = "${module.vault.vault_lb_dns}"
}
