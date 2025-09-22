output "lb_dns" {
  description = "Public DNS name of the load balancer"
  value       = aws_lb.public.dns_name
}

output "lb_private_dns" {
  description = "Private DNS name of the load balancer"
  value       = aws_lb.private.dns_name
}
