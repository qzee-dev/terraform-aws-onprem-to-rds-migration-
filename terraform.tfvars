aws_region = "eu-west-1"

environment = "prod"
project_name = "db-migration"
owner = "platform-engineering"
costcenter = "CC-1001"
repository = "terraform-aws-onprem-to-rds-migration"

vpc_cidr = "10.20.0.0/16"
onprem_cidr = "10.10.0.0/16"

customer_gateway_public_ip = "203.0.113.10"

app_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
db_subnet_cidrs = ["10.20.20.0/24", "10.20.21.0/24"]
dms_subnet_cidrs = ["10.20.30.0/24", "10.20.31.0/24"]

db_name = "appdb"
db_username = "dbadmin"
db_password = "StrongPassword123!"
db_engine_version = "16"
db_instance_class = "db.t3.medium"
db_allocated_storage = 100
db_max_allocated_storage = 500
db_backup_retention_days = 7
db_backup_window = "01:00-02:00"
db_maintenance_window = "sun:03:00-sun:04:00"

dms_replication_instance_class = "dms.t3.medium"
dms_engine_version = "3.5"

source_db_host = "10.10.20.10"
source_db_port = 5432
source_db_username = "migration_user"
source_db_password = "StrongSourcePassword123!"
source_db_name = "appdb"

vpn_tunnel_inside_cidr_1 = "169.254.100.0/30"
vpn_tunnel_inside_cidr_2 = "169.254.101.0/30"

vpn_ike_version = "ikev2"
vpn_dh_group = "group14"
vpn_encryption_algorithm = "AES256"
vpn_integrity_algorithm = "SHA256"
vpn_lifetime = 28800
vpn_pfs = "group14"
