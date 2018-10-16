variable "app_name" {
  description = "Name of Application"
  default     = "vault-puppet-demo"
}

variable "networkEnv" {
  description = "e.g. Dev, Stage, Prod"
  default     = "demo"
}

variable "location" {
  description = "Resource location"
  default     = "West US"
}

variable "instance_count" {
  description = "Number of servers"
  default     = "1"
}

variable "papertrail_token" {}
