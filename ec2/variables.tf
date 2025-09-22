variable "my_vpc_id" {
  description = "The VPC ID for the EC2 security group"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnet ID for public EC2 instances (Nginx)"
  type        = list(string)
}


variable "private_subnet_ids" {
  description = "Subnet ID for private EC2 instances (Apache)"
  type        = list(string)
}
variable "vpc_cidr" {
  description = "The subnet IDs to launch the private load balancer in"
  type        = string
  
}

variable "key_path" {
  description = "The path to the private key file for SSH access"
  type        = string
  default     = "~/.aws/rami-key2.pem"
}