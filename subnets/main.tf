# Public Subnet 1
resource "aws_subnet" "public1" {
  vpc_id                  = var.my_vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-1" }
}

# Public Subnet 2
resource "aws_subnet" "public2" {
  vpc_id                  = var.my_vpc_id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-2" }
}

# Private Subnet 1
resource "aws_subnet" "private1" {
  vpc_id            = var.my_vpc_id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-subnet-1" }
}

# Private Subnet 2
resource "aws_subnet" "private2" {
  vpc_id            = var.my_vpc_id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "private-subnet-2" }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = var.my_vpc_id
  tags   = { Name = "my-igw" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id    = aws_subnet.public1.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.my_vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}
resource "aws_route_table" "private_rt" {
  vpc_id = var.my_vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "private_rt"
  }
}
resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_rt_assoc1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_rt_assoc2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}