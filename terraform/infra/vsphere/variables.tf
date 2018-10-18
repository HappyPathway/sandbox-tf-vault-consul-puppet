variable "disk_size" {
  default = 40
}

variable "vm_name" {
  default = "vault-puppet-client"
}

variable "cpu_count" {
  default = 1
}

variable "memory" {
  default = 2048
}

variable "vm_count" {
  default = 1
}

variable "tag_name" {
  default = "Environment"
}

variable "papertrail_token" {}
