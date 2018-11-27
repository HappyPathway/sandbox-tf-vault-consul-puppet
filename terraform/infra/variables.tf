variable "infra_prefix" {
  default = "tfe-demo-darnold"
}

variable "infra_tags" {
  type = "map"

  default = {
    owner   = "nvalentine"
    ttl     = -1
    project = "vault-puppet-demo"
  }
}

variable "papertrail_token" {}

variable "gcp_project" {}
variable "gcp_credentials" {}
