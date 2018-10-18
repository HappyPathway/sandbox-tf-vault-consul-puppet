module "vault" {
  source        = "git::https://github.com/hashicorp/vault-guides//operations/provision-vault/quick-start/terraform-aws"
  name          = "${var.vault_cluster_name}"
  vault_tags    = "${var.instance_tags}"
  network_tags  = "${var.network_tags}"
  consul_public = "${var.consul_public}"
  vault_public  = "${var.vault_public}"
}

# propagate various outputs from the Vault module for convenience
output "README" {
  value = "${module.vault.zREADME}"
}

output "bastion_public_addrs" {
  value = "${module.vault.bastion_ips_public}"
}

output "bastion_username" {
  value = "${module.vault.bastion_username}"
}

output "ssh_private_key_pem" {
  value = "${module.vault.private_key_pem}"
}

output "ssh_public_key_pem" {
  value = "${module.vault.public_key_pem}"
}

output "ssh_public_key_openssh" {
  value = "${module.vault.public_key_openssh}"
}

output "consul_lb_dns" {
  value = "${module.vault.consul_lb_dns}"
}

output "vault_lb_dns" {
  value = "${module.vault.vault_lb_dns}"
}

output "ssh_key_name" {
  value = "${module.vault.ssh_key_name}"
}
