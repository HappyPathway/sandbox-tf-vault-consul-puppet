module "infra_azure" {
  source = "./modules/infra_azure"
  app_name = "${var.infra_prefix}"
  tags   = "${var.infra_tags}"
  papertrail_token = "${var.papertrail_token}"
  puppet_master_addr = "${module.infra_aws.puppet_master_address_public}"
}
