// Internet gateway for VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.vpc_name, "IGW")
    VPC  = aws_vpc.vpc.id
  }
}

# //Elastic IP for NAT gateway
# resource "aws_eip" "nat_eip" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.internet_gateway]

#   tags = {
#     Name = "NAT gatway EIP"
#   }
# }


# // NAT Gateway
# resource "aws_nat_gateway" "ngw" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id = aws_subnet.public[count.index].id

#   tags = {
#     Name="Main NAT gateway"
#   }

# }

//Route table for public subnet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "Public Route Table"
    Role   = "public"
    VPC    = "aws_vpc.vpc.id"
  }
}

//Route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "Private Route Table"
    Role   = "private"
    VPC    = "aws_vpc.vpc.id"
  }
}

// Public Route
resource "aws_route" "public" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.destination_cidr
  gateway_id             = aws_internet_gateway.internet_gateway.id

}

# // Private Route
# resource "aws_route" "private" {

#     route_table_id = aws_route_table.private.id
#     destination_cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.ngw.id

# }


// Association between public subnet and public route table

resource "aws_route_table_association" "public" {

  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}

// Association between private subnet and private route table

resource "aws_route_table_association" "private" {

  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}