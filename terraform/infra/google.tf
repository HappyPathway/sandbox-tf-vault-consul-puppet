module "infra_google" {
  source = "./modules/infra_google"
  gcp_credentials = "${var.gcp_credentials}"
  gcp_project = "${var.gcp_project}"
  instance_name = "gcp-${var.infra_prefix}"
  prefix = "${var.infra_prefix}"
  tags = "${var.infra_tags["project"]}"
  papertrail_token = "${var.papertrail_token}"
  puppet_master_addr = "${module.infra_aws.puppet_master_address_public}"
  ssh_key = "${module.infra_aws.puppet_ssh_public_key}"
}
