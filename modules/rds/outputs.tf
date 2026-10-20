output "endpoint" {
  value = aws_db_instance.primary.address
}

output "kms_key_arn" {
  value = aws_kms_key.rds.arn
}

output "db_instance_id" {
  value = aws_db_instance.primary.id
}
