# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create an Internet Gateway for the VPC access to the internet
resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "lesson-5-igw"
  }
}

# Create a NAT Gateway for the private subnets to access the internet
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id

  subnet_id = aws_subnet.public_subnet[0].id

  depends_on = [aws_internet_gateway.vpc_internet_gateway]

  tags = {
    Name = "lesson-5-nat"
  }
}