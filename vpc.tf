# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks_gw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.project_name}-gw"
  }
}

# Public Subnets (2)
resource "aws_subnet" "public_subnet_01" {
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.public_subnet_01_block

  tags = {
    Name                                                = "${var.project_name}-public-subnet-01"
    "kubernetes.io/role/elb"                            = 1
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = var.public_subnet_02_block

  tags = {
    Name                                                = "${var.project_name}-public-subnet-02"
    "kubernetes.io/role/elb"                            = 1
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

# Private Subnets (2)
resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.private_subnet_01_block

  tags = {
    Name                                                = "${var.project_name}-private-subnet-01"
    "kubernetes.io/role/internal-elb"                   = 1
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = var.private_subnet_02_block

  tags = {
    Name                                                = "${var.project_name}-private-subnet-02"
    "kubernetes.io/role/internal-elb"                   = 1
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_gw.id
  }

  tags = {
    Name    = "${var.project_name}-public-route-table"
    Network = "${var.project_name}-public"
  }
}

# Private Route Tables (2)
resource "aws_route_table" "private_route_table_01" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_01.id
  }

  tags = {
    Name    = "${var.project_name}-private-route-table-01"
    Network = "${var.project_name}-private"
  }
}

resource "aws_route_table" "private_route_table_02" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_02.id
  }

  tags = {
    Name    = "${var.project_name}-private-route-table-02"
    Network = "${var.project_name}-private"
  }
}

# Elastic IPs (2)
resource "aws_eip" "eip_for_nat_gw" {
  count = 2
  vpc   = true
}


# NAT Gateways (2)
resource "aws_nat_gateway" "nat_gw_01" {
  allocation_id = aws_eip.eip_for_nat_gw.0.id
  subnet_id     = aws_subnet.public_subnet_01.id

  tags = {
    Name = "${var.project_name}-nat-gw-01"
  }
}

resource "aws_nat_gateway" "nat_gw_02" {
  allocation_id = aws_eip.eip_for_nat_gw.1.id
  subnet_id     = aws_subnet.public_subnet_02.id

  tags = {
    Name = "${var.project_name}-nat-gw-02"
  }
}

# Route Table Associations (4)
resource "aws_route_table_association" "public_subnet_01_to_public_route_table" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_02_to_public_route_table" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_01_to_private_route_table_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_route_table_01.id
}

resource "aws_route_table_association" "private_subnet_02_to_private_route_table_02" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_route_table_02.id
}

# Security Groups (1)
resource "aws_security_group" "control_plane_sg" {
  name        = "${var.project_name}-control-plane-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id
}
