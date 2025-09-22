variable "public_sg_id" {
  description = "Security group ID to attach to the load balancer"
  type        = string
}

variable "private_sg_id" {
  description = "Security group ID to attach to the load balancer"
  type        = string
}
variable "nginx_ids" {
  description = "List of public Nginx EC2 instance IDs to attach to the LB"
  type        = list(string)
}

variable "apache_ids" {
  description = "List of public Nginx EC2 instance IDs to attach to the LB"
  type        = list(string)
}

variable "my_vpc_id" {
  description = "VPC ID where the load balancer target group will live"
  type        = string
}


variable "public_subnet_ids" {
  description = "List of public subnet IDs for LB"
  type        = list(string)
}

 
variable "private_subnets_id" {
  description = "The subnet IDs to launch the private load balancer in"
  type        = list(string)
  
}

