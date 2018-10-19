module "infra_aws" {
  source = "./modules/infra_aws"
  prefix = "${var.infra_prefix}"
  tags = "${var.infra_tags}"

  papertrail_token = "${var.papertrail_token}"
}
