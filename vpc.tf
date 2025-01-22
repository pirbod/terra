###################################
# VPC
###################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "challenge-vpc"
  }
}

###################################
# Subnets
###################################
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "challenge-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "challenge-private-subnet-${count.index}"
  }
}

###################################
# Internet Gateway & Route Table (Public)
###################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "challenge-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "challenge-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

###################################
# NAT Gateway & Route Table (Private)
###################################
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnets)
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "challenge-nat-gw-${count.index}"
  }
}

# Create a route table for each private subnet
resource "aws_route_table" "private_rt" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "challenge-private-rt-${count.index}"
  }
}

resource "aws_route" "private_internet_access" {
  count                = length(var.private_subnets)
  route_table_id       = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  # We’re re-using NAT gateways in a round-robin manner for the private subnets
  nat_gateway_id = element(
    aws_nat_gateway.nat_gw[*].id,
    count.index % length(var.public_subnets)
  )
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
