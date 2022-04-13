output "swarna-rds-instance-id" {
  description = "Output of RDS instance ID"
  value = aws_db_instance.swarna-default.id
}
output "swarna-rds-sg-id" {
  description = "Output of RDS Security group ID"
  value = aws_security_group.swarna-rds-sg.id
}