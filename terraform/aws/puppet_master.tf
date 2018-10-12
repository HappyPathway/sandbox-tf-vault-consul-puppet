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

data "template_cloudinit_config" "pe_master_cloudinit" {
  # gzipped user-data causes problems for Puppet default encoding JSON v PSON
  gzip          = false
  # it appears as though base64-encoded might also be causing problems
  base64_encode = false

  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/../templates/pe_master_bootstrap.sh.tpl")}"
  }
}

resource "aws_security_group" "puppet-master" {
  name = "${var.vault_cluster_name}-puppet-master"
  description = "allow all in-bound to the Puppet master"
  vpc_id = "${module.vault.vpc_id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vault_cluster_name}-puppet-master"
  }
}

resource "aws_instance" "puppet-master" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "m1.large"
  tags          = "${merge(var.instance_tags, map("Name", "${var.vault_cluster_name}-puppet-master"))}"
  subnet_id     = "${element(module.vault.subnet_public_ids, 0)}"
  user_data     = "${data.template_cloudinit_config.pe_master_cloudinit.rendered}"
  key_name      = "${module.vault.ssh_key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids = [ "${aws_security_group.puppet-master.id}" ]
}
