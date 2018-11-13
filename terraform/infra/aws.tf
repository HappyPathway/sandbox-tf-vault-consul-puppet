module "infra_aws" {
  source = "./modules/infra_aws"

  prefix = "${var.infra_prefix}"
  tags   = "${var.infra_tags}"

  papertrail_token = "${var.papertrail_token}"
  custom_user_data = "${file("${path.module}/scripts/puppet_agent_bootstrap.sh")}"
}

output "vault_ssh_private_key" {
  value = "${module.infra_aws.vault_ssh_private_key}"
}

output "vault_server_address" {
  value = "${module.infra_aws.vault_server_address_public}"
}

output "consul_ssh_private_key" {
  value = "${module.infra_aws.consul_ssh_private_key}"
}

output "consul_server_address" {
  value = "${module.infra_aws.consul_server_address_public}"
}

output "puppet_master_address" {
  value = "${module.infra_aws.puppet_master_address_public}"
}

output "puppet_ssh_private_key" {
  value = "${module.infra_aws.vault_ssh_private_key}"
}

output "puppet_ssh_public_key" {
  value = "${module.infra_aws.vault_ssh_public_key}"
}
