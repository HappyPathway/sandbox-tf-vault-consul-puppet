variable "infra_prefix" { default = "vault-puppet-demo" }

variable "infra_tags" {
  type = "map"
  default = {
    owner = "nvalentine"
    ttl = -1
  }
}

variable "papertrail_token" {}
