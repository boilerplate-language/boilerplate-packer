locals {
  timestamp   = formatdate("YYYYMMDDhhmmss", timestamp())
  project     = "boilerplate-packer"
  profile     = "packer"
  environment = "dev"
}

variable "version" {
  type    = string
  default = "1.0.0"
}

source "amazon-ebs" "packer-ami" {
  ami_name = "${local.project}-ami"
  profile  = local.profile

  instance_type = "a1.medium"
  region        = "ap-northeast-1"
  source_ami_filter {
    filters = {
      platform-details    = "Red Hat Enterprise Linux"
      architecture        = "arm64"
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
      "tag:Name" : "${local.project}-${local.environment}-vpc"
    }
  }

  subnet_filter {
    filters = {
      "tag:Name" : "${local.project}-${local.environment}-public-subnet-1a"
    }
  }

  security_group_filter {
    filters = {
      "tag:Name" : "${local.project}-${local.environment}-sg"
    }
  }

  iam_instance_profile        = "${local.project}-${local.environment}-iam-role"
  associate_public_ip_address = true

  ssh_keypair_name     = "${local.project}-${local.environment}-keypair"
  ssh_private_key_file = "./config/${local.project}-${local.environment}-keypair"
  ssh_interface        = "public_ip"
  ssh_username         = "ec2-user"

  tags = {
    Name          = "${local.project}-ami"
    SourceAMIID   = "{{ .SourceAMI }}"
    SourceAMIName = "{{ .SourceAMIName }}"
    Version       = var.version
    Created       = local.timestamp
  }
}

build {
  sources = [
    "source.amazon-ebs.packer-ami"
  ]

  provisioner "shell" {
    inline = [
      "echo build ${local.project}-ami"
    ]
  }
}
