output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
  
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}
