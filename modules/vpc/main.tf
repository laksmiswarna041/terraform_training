# VPC
resource "aws_vpc" "swarna-tf2-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.owner_name}-${var.environment}-vpc"
    environment = var.environment
    owner_name = var.owner_name
    mail_id=var.mail_id
  }
}

data "aws_vpc" "vpc_selected" {
 id = aws_vpc.swarna-tf2-vpc.id
  tags={
    environment = "sgb_training"
  }
  filter {
    name = "tag:environment"
    values=["sgb_training"]
  }
}


# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "swarna_igw" {
  vpc_id = data.aws_vpc.vpc_selected.id
  tags = {
    Name        = "${var.owner_name}-${var.environment}-igw"
    environment = var.environment
    owner_name = var.owner_name
    mail_id=var.mail_id
  }
}


# Public subnet
resource "aws_subnet" "swarna_tf2_public_subnet" {
  vpc_id                  = data.aws_vpc.vpc_selected.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.owner_name}-${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
    environment = "${var.environment}"
    owner_name = var.owner_name
    mail_id=var.mail_id
    tier = "public_subnet"
  }
}


# Private Subnet
resource "aws_subnet" "swarna_tf2_private_subnet" {
  vpc_id                  = data.aws_vpc.vpc_selected.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.owner_name}-${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    environment = "${var.environment}"
    owner_name = var.owner_name
    mail_id=var.mail_id
    tier = "private_subnet"
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "sgb_tf2_route_private" {
  vpc_id = data.aws_vpc.vpc_selected.id
  tags = {
    Name        = "${var.owner_name}-${var.environment}-private-route-table"
    environment = "${var.environment}"
    owner_name = var.owner_name
    mail_id=var.mail_id
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "sgb_tf2_route_public" {
  vpc_id = data.aws_vpc.vpc_selected.id

  tags = {
    Name        = "${var.owner_name}-${var.environment}-public-route-table"
    environment = "${var.environment}"
    owner_name = var.owner_name
    mail_id=var.mail_id
  }
}

# Route for Internet Gateway
resource "aws_route" "swarna_public_internet_gateway" {
  route_table_id         = aws_route_table.sgb_tf2_route_public.id
  destination_cidr_block = var.cidr_igw
  gateway_id             = aws_internet_gateway.swarna_igw.id
}


# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "sgb_route_table_public_assn" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.swarna_tf2_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.sgb_tf2_route_public.id
}

resource "aws_route_table_association" "sgb_route_table_private_assn" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.swarna_tf2_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.sgb_tf2_route_private.id
}
#ingress rules for security group dynamic block
locals{
  ingress_rules = [{
    port = var.port_443
    description = "ingress rules for port 443"
  },
  {
    port = var.port_80
    description = "ingress rules for port  80"
  },
  {
    port = var.port_22
    description = "ingree rules for port 22"
  }]
}
# Default Security Group of VPC
resource "aws_security_group" "sgb_default" {
  name        = "${var.owner_name}-${var.environment}-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = data.aws_vpc.vpc_selected.id
  depends_on = [
    aws_vpc.swarna-tf2-vpc
  ]
  lifecycle{
    create_before_destroy = true
  }
  dynamic "ingress"{
    for_each = local.ingress_rules
    content{
      description = ingress.value.description
      port = ingress.value.port
      protocol = "tcp"
      cidr_blocks = [var.cidr_igw]
    }
  }

  egress {
    from_port = var.port_all
    to_port   = var.port_all
    protocol  = var.protocol_all
    self      = true
  }

  tags = {
    Name        = "${var.owner_name}-${var.environment}-default-sg"
    environment = "${var.environment}"
    owner_name = var.owner_name
    mail_id=var.mail_id
  }
}
