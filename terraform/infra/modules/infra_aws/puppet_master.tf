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

data "template_file" "bootstrap_sh" {
  template = "${file("${path.module}/../../templates/pemaster_bootstrap.sh.tpl")}"

  vars {
    papertrail_token = "${var.papertrail_token}"
    logic = "${file("${path.module}/../../scripts/pemaster_bootstrap.sh")}"
  }
}

data "template_cloudinit_config" "pemaster_cloudinit" {
  # gzipped user-data causes problems for Puppet default encoding JSON v PSON
  gzip = false

  # it appears as though base64-encoded might also be causing problems
  base64_encode = false

  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bootstrap_sh.rendered}"
  }
}

resource "aws_security_group" "puppet-master" {
  name        = "${var.prefix}-puppet-master"
  description = "allow all in-bound to the Puppet master"
  vpc_id      = "${module.vault.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-puppet-master"
  }
}

resource "aws_instance" "puppet-master" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "m1.large"
  tags          = "${merge(var.tags, map("Name", "${var.prefix}-puppet-master"))}"
  subnet_id     = "${element(module.vault.subnet_public_ids, 0)}"

  user_data     = "${data.template_cloudinit_config.pemaster_cloudinit.rendered}"
  key_name                    = "${module.vault.ssh_key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.puppet-master.id}"]

  tags {
    Name = "${var.prefix}-vault-puppet"
  }
}
