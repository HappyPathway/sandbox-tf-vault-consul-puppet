module "infra_google" {
  source = "./modules/infra_google"

  gcp_credentials = "${var.gcp_credentials}"
  gcp_project = "${var.gcp_project}"

  instance_name = "gcp-${var.infra_prefix}"
  prefix = "${var.infra_prefix}"
  tags = "${var.tags["project"]}"

  papertrail_token = "${var.papertrail_token}"
}