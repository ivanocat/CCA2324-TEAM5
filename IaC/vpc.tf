data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  min_availability_zones = min(var.min-az, length(data.aws_availability_zones.available.names))
  availability_zones = data.aws_availability_zones.available.names
  private_subnets_per_az = 2
  private_subnets_suffixes = ["app", "app", "data", "data"]
}

# Virtual Private Cloud
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                   = local.min_availability_zones
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-public-${local.availability_zones[count.index]}-web"
    Tier = "public"
  }
}

# The first 10 IP's are for public subnets, next ones for private.
resource "aws_subnet" "private" {
  count                   = local.min_availability_zones * local.private_subnets_per_az
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.availability_zones[count.index % local.min_availability_zones]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 10 + count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-subnet-private-${local.availability_zones[count.index % local.min_availability_zones]}-${local.private_subnets_suffixes[count.index]}"
    Tier = "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Elastic IP for the NAT Gateway
resource "aws_eip" "eip_natgw" {
  vpc = true

  tags = {
    Name = "${var.prefix}-eip"
  }
}

# NAT Gateway (Only one for all public subnets)
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip_natgw.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.prefix}-natgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Custom Route Tables & associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-public-custom-rtb"
    Tier = "public"
  }
}
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.prefix}-private-custom-rtb"
    Tier = "private"
  }
}
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

# Security Groups & associations
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from Anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-web-sg"
  }
}

# Application ingress ports to be determined
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow traffic only from web-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Anything from web SG"
    from_port   = 0
    to_port     = 0
    protocol    = -1

    security_groups = [
      "${aws_security_group.web.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-app-sg"
  }
}

# Data ingress ports to be determined
resource "aws_security_group" "data" {
  name        = "data-sg"
  description = "Allow traffic only from app-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Anything from app SG"
    from_port   = 0
    to_port     = 0
    protocol    = -1

    security_groups = [
      "${aws_security_group.app.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-data-sg"
  }
}