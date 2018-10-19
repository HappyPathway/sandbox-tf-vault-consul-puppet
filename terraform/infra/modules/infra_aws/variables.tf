variable "instance_tags" {
  type = "map"

  default = {
    owner = "nvalentine"
    ttl   = -1
  }
}

variable "network_tags" {
  type = "map"

  default = {
    owner = "nvalentine"
    ttl   = -1
  }
}

variable "consul_cluster_name" {
  default = "vault-puppet-demo"
}

variable "vault_cluster_name" {
  default = "vault-puppet-demo"
}

variable "pe_download_uri" {
  default = "https://pm.puppet.com/cgi-bin/download.cgi?arch=amd64&dist=ubuntu&rel=18.04&ver=latest"
}

variable "consul_public" {
  default = false
}

variable "vault_public" {
  default = false
}

variable "papertrail_token" {}
