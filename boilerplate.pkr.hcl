locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  prefix    = "${var.project}-${var.environment}"
}

variable "project" {
  type = string
}

variable "profile" {
  type = string
}

variable "environment" {
  type = string
}

variable "ami_rhel_version" {
  type = string
}

variable "ami_rhel_architecture" {
  type = string
}

variable "ami_instance_type" {
  type = string
}

variable "packer_version" {
  type = string
}

variable "goss_version" {
  type = string
}

variable "goss_architecture" {
  type = string
}

source "amazon-ebs" "packer-ami" {
  ami_name = "${var.project}-ami"
  profile  = var.profile

  instance_type = var.ami_instance_type # 無料トライアルは、2021 年 12 月 31 日までの期間限定
  region        = "ap-northeast-1"
  source_ami_filter {
    filters = {
      name                = "RHEL-${var.ami_rhel_version}*"
      platform-details    = "Red Hat Enterprise Linux"
      architecture        = var.ami_rhel_architecture
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 10
  }

  vpc_filter {
    filters = {
      "tag:Name" : "${local.prefix}-vpc"
    }
  }

  subnet_filter {
    filters = {
      "tag:Name" : "${local.prefix}-public-subnet-1a"
    }
  }

  security_group_filter {
    filters = {
      "tag:Name" : "${local.prefix}-sg"
    }
  }

  iam_instance_profile        = "${local.prefix}-iam-role"
  associate_public_ip_address = true

  ssh_keypair_name     = "${local.prefix}-keypair"
  ssh_private_key_file = "./config/${local.prefix}-keypair"
  ssh_interface        = "public_ip"
  ssh_username         = "ec2-user"

  tags = {
    Name          = "${local.prefix}-ami"
    SourceAMIID   = "{{ .SourceAMI }}"
    SourceAMIName = "{{ .SourceAMIName }}"
    Version       = var.packer_version
    Created       = local.timestamp
  }
}

build {
  sources = [
    "source.amazon-ebs.packer-ami"
  ]

  provisioner "shell" {
    inline = [
      # test network to public
      "ping -c 2 www.google.com",

      # configure subscription
      # ref. https://dev.classmethod.jp/articles/tsnote-ec2-dnf-upgrade-error-001/
      "sudo sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/subscription-manager.conf",
      "sudo cat /etc/yum/pluginconf.d/subscription-manager.conf",

      # install all required packages
      "sudo yum update -y",
      "sudo yum install -y ansible"
    ]
  }

  # provisioner "goss" {
  #   skip_install = false
  #   arch         = var.goss_architecture
  #   version      = var.goss_version

  #   tests = [
  #     "tests/goss.yaml"
  #   ]
  #   use_sudo = true
  # }

  provisioner "shell" {
    inline = [
      "rm -rf /tmp/tests",
      "rm -rf /tmp/goss-*"
    ]
  }
}
