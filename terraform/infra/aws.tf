module "infra_aws" {
  source = "./modules/infra_aws"

  prefix = "${var.infra_prefix}"
  tags = "${var.infra_tags}"

  papertrail_token = "${var.papertrail_token}"
}

output "ssh_private_key" {
  value = "${module.infra_aws.ssh_private_key}"
}

output "vault_server_address" {
  value = "${module.infra_aws.vault_server_address_public}"
}

output "consul_server_address" {
  value = "${module.infra_aws.consul_server_address_public}"
}
