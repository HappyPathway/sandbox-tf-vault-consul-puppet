module "infra_vsphere" {
  source           = "./modules/infra_vsphere"
  vm_name          = "${var.infra_prefix}"
  papertrail_token = "${var.papertrail_token}"
}
