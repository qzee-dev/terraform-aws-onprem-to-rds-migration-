output "vpc_id" {
  description = "The VPC ID."
  value       = module.network.vpc_id
}

output "db_subnet_ids" {
  description = "Private DB subnet IDs."
  value       = module.network.db_subnet_ids
}

output "rds_endpoint" {
  description = "The RDS endpoint to use after cutover."
  value       = module.rds.endpoint
}

output "dms_replication_instance_arn" {
  description = "ARN of the DMS replication instance."
  value       = module.dms.replication_instance_arn
}

output "vpn_connection_id" {
  description = "The AWS Site-to-Site VPN connection ID."
  value       = module.vpn.vpn_connection_id
}

output "vpn_tunnel1_ip" {
  description = "The first VPN tunnel IP."
  value       = module.vpn.tunnel1_ip
}

output "vpn_tunnel2_ip" {
  description = "The second VPN tunnel IP."
  value       = module.vpn.tunnel2_ip
}
