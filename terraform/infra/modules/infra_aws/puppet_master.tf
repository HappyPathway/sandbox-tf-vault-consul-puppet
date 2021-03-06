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

data "template_file" "pemaster_bootstrap_sh" {
  template = "${file("${path.module}/templates/pemaster_bootstrap.sh.tpl")}"

  vars {
    papertrail_token         = "${var.papertrail_token}"
    puppet_master_public_dns = "${var.prefix}.hashidemos.io"
    cluster_name             = "${var.prefix}"
    logic                    = "${file("${path.module}/scripts/pemaster_bootstrap.sh")}"
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
    content      = "${data.template_file.pemaster_bootstrap_sh.rendered}"
  }
}

resource "aws_instance" "puppet-master" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "m1.large"
  tags          = "${merge(var.tags, map("Name", "puppet-master-${var.prefix}"))}"
  subnet_id     = "${element(module.vault.subnet_public_ids, 0)}"

  user_data                   = "${data.template_cloudinit_config.pemaster_cloudinit.rendered}"
  key_name                    = "${module.vault.ssh_key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.puppet-master.id}"]
}

data "aws_route53_zone" "hashidemos_io" {
  name         = "hashidemos.io"
  private_zone = false
}

resource "aws_route53_record" "vault-puppet" {
  zone_id = "${data.aws_route53_zone.hashidemos_io.id}"
  name    = "${var.prefix}.hashidemos.io"
  type    = "CNAME"
  ttl     = 5
  records = ["${aws_instance.puppet-master.public_dns}"]
}

output "puppet_master_address_public" {
  value = "${aws_instance.puppet-master.public_dns}"
}

output "puppet_ssh_public_key" {
  value = "${module.vault.public_key_openssh}"
}
