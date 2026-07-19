# Route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "public-route-table"
  }
}

# Route internet traffic through the Internet Gateway
resource "aws_route" "public_internet_route" {
  route_table_id = aws_route_table.public_route_table.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.vpc_internet_gateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}




# Route table for private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Route internet traffic through the NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id = aws_route_table.private_route_table.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}