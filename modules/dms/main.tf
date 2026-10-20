resource "aws_kms_key" "dms" {
  description             = "Key for DMS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dms-kms"
  })
}

resource "aws_kms_alias" "dms" {
  name          = "alias/${var.project_name}-${var.environment}-dms"
  target_key_id = aws_kms_key.dms.key_id
}

resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id = "${var.project_name}-${var.environment}-dms-subnets"
  subnet_ids                 = var.subnet_ids
}

resource "aws_dms_replication_instance" "this" {
  allocated_storage       = 50
  apply_immediately       = true
  auto_minor_version_upgrade = true
  availability_zone       = var.subnet_ids[0]
  publicly_accessible     = false
  replication_instance_class = var.replication_instance_class
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids  = [var.security_group_id]
  kms_key_arn             = aws_kms_key.dms.arn
  engine_version          = var.dms_engine_version

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dms"
  })
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.project_name}-${var.environment}-source"
  endpoint_type = "source"
  engine_name   = "postgres"

  username = var.source_db_username
  password = var.source_db_password
  server_name = var.source_db_host
  port = var.source_db_port
  database_name = var.source_db_name
  ssl_mode = "require"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-source-endpoint"
  })
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "${var.project_name}-${var.environment}-target"
  endpoint_type = "target"
  engine_name   = "postgres"

  username = var.target_db_username
  password = var.target_db_password
  server_name = var.target_db_host
  port = 5432
  database_name = var.target_db_name
  ssl_mode = "require"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-target-endpoint"
  })
}

resource "aws_dms_replication_task" "this" {
  replication_task_id = "${var.project_name}-${var.environment}-replication-task"
  migration_type      = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn

  table_mappings = jsonencode({
    "rules": [
      {
        "rule-type" = "selection"
        "rule-id" = "1"
        "rule-name" = "public_access"
        "object-locator" = {
          "schema-name" = "public"
          "table-name" = "%"
        }
        "rule-action" = "include"
      }
    ]
  })

  start_time = null

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-migration-task"
  })
}

resource "aws_cloudwatch_metric_alarm" "dms_replication_lag" {
  alarm_name          = "${var.project_name}-${var.environment}-dms-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/DMS"
  period              = 300
  statistic           = "Average"
  threshold           = 120

  dimensions = {
    ReplicationInstanceIdentifier = aws_dms_replication_instance.this.replication_instance_arn
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dms-lag-alarm"
  })
}
