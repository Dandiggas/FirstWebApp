resource "aws_route_table" "DanRoute" {
  vpc_id = aws_vpc.DanVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DanGateway.id
  }

  tags = {
    Name = "DanRoute"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.DanSubnet.id
  route_table_id = aws_route_table.DanRoute.id
}