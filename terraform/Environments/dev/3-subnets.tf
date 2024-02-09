resource "aws_subnet" "DanSubnet" {
  vpc_id            = aws_vpc.DanVpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "DanSubnet"
  }
  # Auto-assign public IPv4 addresses to instances launched in this subnet
  map_public_ip_on_launch = true
}