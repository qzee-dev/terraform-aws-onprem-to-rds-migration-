provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      CostCenter  = var.costcenter
      ManagedBy   = "terraform"
      Repository  = var.repository
    }
  }
}
