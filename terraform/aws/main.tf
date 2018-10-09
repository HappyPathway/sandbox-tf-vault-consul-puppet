provider "aws" {
}

variable "tags" {
  type = "map"
  default = {
    owner = "nvalentine"
    ttl = -1
  }
}

variable "consul_cluster_name" {
  default = "vault-puppet-demo"
}

variable "vault_cluster_name" {
  default = "vault-puppet-demo"
}

# module "consul" {
#   source = "git::https://github.com/hashicorp/consul-guides//operations/provision-consul/quick-start/terraform-aws"
#   name = "${var.consul_cluster_name}"
#   consul_tags = "${var.tags}"
#   network_tags = "${var.tags}"
# }

module "vault" {
  source = "git::https://github.com/hashicorp/vault-guides//operations/provision-vault/quick-start/terraform-aws"
  name = "${var.vault_cluster_name}"
  vault_tags = "${var.tags}"
  network_tags = "${var.tags}"
}

output "README" {
  value = "${module.vault.zREADME}"
}
