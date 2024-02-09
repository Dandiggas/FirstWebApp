resource "aws_internet_gateway" "DanGateway" {
  vpc_id = aws_vpc.DanVpc.id

  tags = {
    Name = "DanGateway"
  }
}