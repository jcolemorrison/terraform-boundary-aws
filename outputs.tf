output "service_endpoint" {
  description = "The public ALB endpoint for the public application."
  value = aws_lb.public.dns_name
}

output "controller_token" {
  value = boundary_worker.worker_one.worker_generated_auth_token
}