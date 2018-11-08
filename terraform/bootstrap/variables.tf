variable "tfe_hostname" { default = "ptfe.this-demo.rocks" }
variable "tfe_api_token" {}
variable "tfe_org_name" { default = "SE_nathan_valentine_demos" }

variable "workspace_name" { default = "vault-puppet-demo" }
variable "workspace_auto_apply" { default = true }
variable "workspace_vcs_repo" { default = "nrvale0/sandbox-tf-vault-consul-puppet" }
variable "workspace_branch" { default = "master" }
variable "workspace_oauth_token" {}

variable "workspace_papertrail_token" {}

variable "workspace_AWS_SECRET_KEY" {}
variable "workspace_AWS_ACCESS_KEY_ID" {}
variable "workspace_AWS_DEFAULT_REGION" { default = "us-west-2" }

variable "workspace_ARM_CLIENT_ID" {}
variable "workspace_ARM_CLIENT_SECRET" {}
variable "workspace_ARM_SUBSCRIPTION_ID" {}
variable "workspace_ARM_TENANT_ID" {}

variable "workspace_gcp_project" {}
variable "workspace_gcp_credentials" {}

variable "workspace_VSPHERE_ALLOW_UNVERIFIED_SSL" { default = true }
variable "workspace_VSPHERE_USER" {}
variable "workspace_VSPHERE_PASSWORD" {}
variable "workspace_VSPHERE_SERVER" {}

variable "workspace_TFE_PARALLELISM" { default = 10 }
