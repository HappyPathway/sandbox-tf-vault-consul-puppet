provider "tfe" {
  hostname = "${var.tfe_hostname}"
  token = "${var.tfe_api_token}"
}

resource "tfe_workspace" "workspace" {
  name = "${var.workspace_name}"
  organization = "${var.tfe_org_name}"
  auto_apply = "${var.workspace_auto_apply}"
  working_directory = "terraform/infra"

  vcs_repo {
    identifier = "${var.workspace_vcs_repo}"
    branch = "${var.workspace_branch}"
    oauth_token_id = "${var.workspace_oauth_token}"
  }
}

resource "tfe_variable" "CONFIRM_DESTROY" {
  key = "CONFIRM_DESTROY"
  value = "1"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
}

resource "tfe_variable" "papertrail_token" {
  key = "papertrail_token"
  value = "${var.workspace_papertrail_token}"
  category = "terraform"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "AWS_ACCESS_KEY_ID" {
  key = "AWS_ACCESS_KEY_ID"
  value = "${var.workspace_AWS_ACCESS_KEY_ID}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "AWS_SECRET_KEY" {
  key = "AWS_SECRET_KEY"
  value = "${var.workspace_AWS_SECRET_KEY}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "AWS_DEFAULT_REGION" {
  key = "AWS_DEFAULT_REGION"
  value = "${var.workspace_AWS_DEFAULT_REGION}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
}


resource "tfe_variable" "ARM_CLIENT_ID" {
  key = "ARM_CLIENT_ID"
  value = "${var.workspace_ARM_CLIENT_ID}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "ARM_CLIENT_SECRET" {
  key = "ARM_CLIENT_SECRET"
  value = "${var.workspace_ARM_CLIENT_SECRET}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "ARM_SUBSCRIPTION_ID" {
  key =  "ARM_SUBSCRIPTION_ID"
  value = "${var.workspace_ARM_SUBSCRIPTION_ID}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "ARM_TENANT_ID" {
  key = "ARM_TENANT_ID"
  value = "${var.workspace_ARM_TENANT_ID}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "gcp_project" {
  key = "gcp_project"
  value = "${var.workspace_gcp_project}"
  category = "terraform"
  workspace_id = "${tfe_workspace.workspace.id}"
}

resource "tfe_variable" "gcp_credentials" {
  key = "gcp_credentials"
  value = "${var.workspace_gcp_credentials}"
  category = "terraform"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "VSPHERE_ALLOW_UNVERIFIED_SSL" {
  key = "VSPHERE_ALLOW_UNVERIFIED_SSL"
  value = "${var.workspace_VSPHERE_ALLOW_UNVERIFIED_SSL}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
}

resource "tfe_variable" "VSPHERE_USER" {
  key = "VSPHERE_USER"
  value = "${var.workspace_VSPHERE_USER}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "VSPHERE_PASSWORD" {
  key = "VSPHERE_PASSWORD"
  value = "${var.workspace_VSPHERE_PASSWORD}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "VSPHERE_SERVER" {
  key = "VSPHERE_SERVER"
  value = "${var.workspace_VSPHERE_SERVER}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
  sensitive = true
}

resource "tfe_variable" "TFE_PARALLELISM" {
  key = "TFE_PARALLELISM"
  value = "${var.workspace_TFE_PARALLELISM}"
  category = "env"
  workspace_id = "${tfe_workspace.workspace.id}"
}

resource "tfe_variable" "puppet_master_public_dns" {
  key = "puppet_master_public_dns"
  value = "${var.workspace_puppet_master_public_dns}"
  category = "terraform"
  workspace_id = "${tfe_workspace.workspace.id}"
}
