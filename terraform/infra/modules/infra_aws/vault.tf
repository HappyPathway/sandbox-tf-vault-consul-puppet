module "vault" {
  source        = "git::https://github.com/hashicorp/vault-guides//operations/provision-vault/quick-start/terraform-aws"
  name          = "${var.prefix}"
  vault_tags    = "${var.tags}"
  network_tags  = "${var.tags}"
  consul_public = "${var.consul_is_public}"
  vault_public  = "${var.vault_is_public}"
}

output "ssh_private_key" {
  value = "${module.vault.private_key_pem}"
}
