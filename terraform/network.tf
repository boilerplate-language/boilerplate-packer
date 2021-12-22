# =============================================================================
# VPC
# =============================================================================

resource "aws_vpc" "vpc" {
  cidr_block                       = "192.168.0.0/20"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Project     = var.project
    Environment = var.environment
  }
}

# =============================================================================
# SUBNET 
# =============================================================================

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project}-${var.environment}-public-subnet-1a"
    Project     = var.project
    Environment = var.environment
    Type        = "public"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "192.168.3.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.project}-${var.environment}-private-subnet-1a"
    Project     = var.project
    Environment = var.environment
    Type        = "private"
  }
}


# =============================================================================
# ROUTE TABLE 
# =============================================================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-public-rt"
    Project     = var.project
    Environment = var.environment
    Type        = "public"
  }
}

resource "aws_route_table" "priavte_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-priavte-rt"
    Project     = var.project
    Environment = var.environment
    Type        = "priavte"
  }
}

resource "aws_route_table_association" "public_rt_1a" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet_1a.id
}

resource "aws_route_table_association" "private_rt_1a" {
  route_table_id = aws_route_table.priavte_rt.id
  subnet_id      = aws_subnet.private_subnet_1a.id
}

# =============================================================================
# INTERNET GATEWAY 
# =============================================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-igw"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_route" "public_rt_igw_r" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# =============================================================================
# SECURITY GROUP
# =============================================================================

resource "aws_security_group" "packer_sg" {
  name        = "${var.project}-${var.environment}-sg"
  description = "security group for packer"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "out_http" {
  security_group_id = aws_security_group.packer_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  prefix_list_ids   = [data.aws_prefix_list.s3_pl.id]
}

resource "aws_security_group_rule" "out_https" {
  security_group_id = aws_security_group.packer_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_ids   = [data.aws_prefix_list.s3_pl.id]
}
resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.packer_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}
