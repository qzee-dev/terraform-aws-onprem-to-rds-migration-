output "vpc_id" {
  value = aws_vpc.this.id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "dms_subnet_ids" {
  value = aws_subnet.dms[*].id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "dms_security_group_id" {
  value = aws_security_group.dms.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.this.id
}
