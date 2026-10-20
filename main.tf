module "network" {
  source = "./modules/network"

  environment     = var.environment
  project_name    = var.project_name
  owner           = var.owner
  costcenter      = var.costcenter
  vpc_cidr        = var.vpc_cidr
  app_subnet_cidrs = var.app_subnet_cidrs
  db_subnet_cidrs  = var.db_subnet_cidrs
  dms_subnet_cidrs = var.dms_subnet_cidrs
  onprem_cidr     = var.onprem_cidr

  tags = local.common_tags
}

module "vpn" {
  source = "./modules/vpn"

  environment     = var.environment
  project_name    = var.project_name
  vpc_id          = module.network.vpc_id
  customer_gateway_public_ip = var.customer_gateway_public_ip
  onprem_cidr     = var.onprem_cidr
  vpn_tunnel_inside_cidr_1 = var.vpn_tunnel_inside_cidr_1
  vpn_tunnel_inside_cidr_2 = var.vpn_tunnel_inside_cidr_2
  vpn_ike_version = var.vpn_ike_version
  vpn_dh_group    = var.vpn_dh_group
  vpn_encryption_algorithm = var.vpn_encryption_algorithm
  vpn_integrity_algorithm = var.vpn_integrity_algorithm
  vpn_lifetime    = var.vpn_lifetime
  vpn_pfs         = var.vpn_pfs

  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  environment     = var.environment
  project_name    = var.project_name
  owner           = var.owner
  costcenter      = var.costcenter
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
  db_backup_window = var.db_backup_window
  db_maintenance_window = var.db_maintenance_window

  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.db_subnet_ids
  app_security_group_id = module.network.app_security_group_id
  dms_security_group_id = module.network.dms_security_group_id
  tags = local.common_tags
}

module "dms" {
  source = "./modules/dms"

  environment     = var.environment
  project_name    = var.project_name
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.dms_subnet_ids
  source_db_host  = var.source_db_host
  source_db_port  = var.source_db_port
  source_db_username = var.source_db_username
  source_db_password = var.source_db_password
  source_db_name  = var.source_db_name
  target_db_host  = module.rds.endpoint
  target_db_name  = var.db_name
  target_db_username = var.db_username
  target_db_password = var.db_password
  replication_instance_class = var.dms_replication_instance_class
  dms_engine_version = var.dms_engine_version
  kms_key_arn     = module.rds.kms_key_arn
  security_group_id = module.network.dms_security_group_id
  tags = local.common_tags
}
