output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.web.public_ip
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.web.private_ip
}

output "website_url" {
  description = "Application URL"
  value       = "http://${aws_instance.web.public_ip}"
}