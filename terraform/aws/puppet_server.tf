data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "pe_master_bootstrap" {
  template = "${file("${path.module}/templates/pe_master_bootstrap.sh.tpl")}"

  vars {
  }
}

data "template_cloudinit_config" "pe_master_cloudinit" {
  gzip = true
  base64_encode = true

  part {
    filename = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content = "${data.template_file.pe_master_bootstrap.rendered}"
  }
}

resource "aws_instance" "puppet-master" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "m1.large"
  tags = "${merge(var.instance_tags, map("Name", "${var.vault_cluster_name}-puppet-master"))}"
  subnet_id = "${element(module.vault.subnet_public_ids, 0)}"
  user_data = "${data.template_cloudinit_config.pe_master_cloudinit.rendered}"
  key_name = "${module.vault.ssh_key_name}"
}
