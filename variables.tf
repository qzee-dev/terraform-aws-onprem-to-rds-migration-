variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Name of the workload project."
  type        = string
  default     = "db-migration"
}

variable "owner" {
  description = "Owner or team name."
  type        = string
  default     = "platform-engineering"
}

variable "costcenter" {
  description = "Finance cost center."
  type        = string
  default     = "CC-1001"
}

variable "repository" {
  description = "Infrastructure repository identifier."
  type        = string
  default     = "terraform-aws-onprem-to-rds-migration"
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR block."
  type        = string
  default     = "10.20.0.0/16"
}

variable "onprem_cidr" {
  description = "On-prem network CIDR routed over Site-to-Site VPN."
  type        = string
  default     = "10.10.0.0/16"
}

variable "customer_gateway_public_ip" {
  description = "Public IP of the on-prem customer gateway."
  type        = string
}

variable "app_subnet_cidrs" {
  description = "Private app subnet CIDRs."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Private DB subnet CIDRs."
  type        = list(string)
  default     = ["10.20.20.0/24", "10.20.21.0/24"]
}

variable "dms_subnet_cidrs" {
  description = "Private DMS subnet CIDRs."
  type        = list(string)
  default     = ["10.20.30.0/24", "10.20.31.0/24"]
}

variable "db_name" {
  description = "Target PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Target PostgreSQL admin username."
  type        = string
  default     = "dbadmin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_username))
    error_message = "Database username must be a valid PostgreSQL username."
  }
}

variable "db_password" {
  description = "Target PostgreSQL admin password. Store secret in a secure vault in production."
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "PostgreSQL version in RDS."
  type        = string
  default     = "16"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Initial storage size in GiB."
  type        = number
  default     = 100
}

variable "db_max_allocated_storage" {
  description = "Maximum storage autoscaling size in GiB."
  type        = number
  default     = 500
}

variable "db_backup_retention_days" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "db_maintenance_window" {
  type    = string
  default = "sun:03:00-sun:04:00"
}

variable "db_backup_window" {
  type    = string
  default = "01:00-02:00"
}

variable "dms_replication_instance_class" {
  description = "DMS replication instance class."
  type        = string
  default     = "dms.t3.medium"
}

variable "dms_engine_version" {
  description = "DMS engine version."
  type        = string
  default     = "3.5"
}

variable "source_db_host" {
  description = "On-prem source database hostname or IP."
  type        = string
}

variable "source_db_port" {
  description = "On-prem source database port."
  type        = number
  default     = 5432
}

variable "source_db_username" {
  description = "Username for on-prem source DB used for DMS."
  type        = string
}

variable "source_db_password" {
  description = "Password for on-prem source DB user used for DMS."
  type        = string
  sensitive   = true
}

variable "source_db_name" {
  description = "On-prem database name to migrate."
  type        = string
}

variable "vpn_tunnel_inside_cidr_1" {
  description = "Tunnel inside CIDR for first VPN tunnel."
  type        = string
  default     = "169.254.100.0/30"
}

variable "vpn_tunnel_inside_cidr_2" {
  description = "Tunnel inside CIDR for second VPN tunnel."
  type        = string
  default     = "169.254.101.0/30"
}

variable "vpn_ike_version" {
  description = "IKE version for VPN."
  type        = string
  default     = "ikev2"

  validation {
    condition     = contains(["ikev1", "ikev2"], var.vpn_ike_version)
    error_message = "vpn_ike_version must be one of ikev1 or ikev2."
  }
}

variable "vpn_dh_group" {
  description = "IPsec DH group for VPN."
  type        = string
  default     = "group14"

  validation {
    condition     = contains(["group2", "group14", "group16"], var.vpn_dh_group)
    error_message = "vpn_dh_group must be one of group2, group14, group16."
  }
}

variable "vpn_encryption_algorithm" {
  description = "IPsec encryption."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "AES128", "AES192"], var.vpn_encryption_algorithm)
    error_message = "vpn_encryption_algorithm must be one of AES256, AES128, AES192."
  }
}

variable "vpn_integrity_algorithm" {
  description = "IPsec integrity."
  type        = string
  default     = "SHA256"

  validation {
    condition     = contains(["SHA256", "SHA1", "MD5"], var.vpn_integrity_algorithm)
    error_message = "vpn_integrity_algorithm must be one of SHA256, SHA1, MD5."
  }
}

variable "vpn_lifetime" {
  description = "IPsec lifetime in seconds."
  type        = number
  default     = 28800
}

variable "vpn_pfs" {
  description = "IPsec PFS setting."
  type        = string
  default     = "group14"

  validation {
    condition     = contains(["group2", "group14", "group16"], var.vpn_pfs)
    error_message = "vpn_pfs must be one of group2, group14, group16."
  }
}
