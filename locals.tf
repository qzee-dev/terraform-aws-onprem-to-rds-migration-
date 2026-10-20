locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CostCenter  = var.costcenter
    ManagedBy   = "terraform"
    Repository  = var.repository
  }

  name_prefix = "${var.project_name}-${var.environment}"

  db_port = 5432
  dms_port = 5432
}
