output "public_security_group_id" {
  description = "public ec2 instances security group id"
  value       = aws_security_group.sgb-pubec2sg.id
}

output "ec2_instances_id" {
  description = "Ec2 instance ids"
  value       = aws_instance.sgb_ec2_public.id
}

output "ec2_public_ip" {
  description = "Ec2 public IPs"
  value       = aws_instance.sgb_ec2_public.public_ip
}