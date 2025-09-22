output "nginx_ids" {
  description = "IDs of the public Nginx EC2 instances"
  value       = aws_instance.nginx[*].id
}

output "nginx_public_ips" {
  value = aws_instance.nginx[*].public_ip
}

output "apache_ids" {
  description = "IDs of the private Apache EC2 instances"
  value       = aws_instance.apache[*].id
}

output "sg_public_id" {
  description = "Security Group ID used by all public EC2 instances"
  value       = aws_security_group.sg-public-ec2.id
}



output "sg_private_id" {
  description = "Security Group ID used by all private EC2 instances"
  value       = aws_security_group.sg-private-ec2.id
}

output "sg-private-ec2" {
  description = "Security Group ID used by all private EC2 instances"
  value       = aws_security_group.sg-private-ec2.id
}

output "sg-public-ec2" {
  description = "Security Group ID used by all public EC2 instances"
  value       = aws_security_group.sg-public-ec2.id
  
}