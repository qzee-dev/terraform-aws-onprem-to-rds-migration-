resource "aws_kms_key" "rds" {
  description             = "Key for RDS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-rds-kms"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_db_instance" "primary" {
  identifier             = "${var.project_name}-${var.environment}-postgres"
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  max_allocated_storage  = var.db_max_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds.arn
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  port                   = 5432
  publicly_accessible    = false
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.app_security_group_id, var.dms_security_group_id]
  backup_retention_period = var.db_backup_retention_days
  backup_window          = var.db_backup_window
  maintenance_window     = var.db_maintenance_window
  deletion_protection    = true
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final"
  apply_immediately      = false
  copy_tags_to_snapshot  = true
  auto_minor_version_upgrade = true
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  monitoring_interval = 60
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-postgres-primary"
    Role = "database"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_iam_role" "monitoring" {
  name = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-rds-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-rds-connections-alarm"
  })
}
