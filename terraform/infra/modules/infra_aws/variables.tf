variable "prefix" {}
variable "tags" {
  type = "map"
  default = {}
}
variable "consul_is_public" { default = true }
variable "vault_is_public"  { default = true }
variable "papertrail_token" {}
