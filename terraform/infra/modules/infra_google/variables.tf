variable "gcp_credentials" {}
variable "gcp_project" {}
variable "gcp_region" { default = "us-east1" }
variable "gcp_zone" { default = "us-east1-b" }

variable "machine_type" { default = "n1-standard-1" }

variable "instance_name" { default = "gcp-instance" }
variable "image" { default = "debian-cloud/debian-9" }

variable "papertrail_token" {}
variable "prefix" {}
variable "tags" {
  type = "list"
  default = []
}

variable "puppet_master_addr" {}
variable "ssh_key" {}
