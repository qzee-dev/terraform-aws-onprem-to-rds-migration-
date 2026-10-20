resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_flow_log" "vpc" {
  log_destination_type = "cloud-watch-logs"
  log_group_name       = "/aws/vpc/${var.project_name}-${var.environment}"
  iam_role_arn         = aws_iam_role.flowlog.arn
  vpc_id               = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-flowlog"
  })
}

resource "aws_iam_role" "flowlog" {
  name = "${var.project_name}-${var.environment}-vpc-flowlog-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-flowlog-role"
  })
}

resource "aws_iam_role_policy" "flowlog" {
  name = "${var.project_name}-${var.environment}-vpc-flowlog-policy"
  role = aws_iam_role.flowlog.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_subnet" "app" {
  count = length(var.app_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
    Tier = "app"
  })
}

resource "aws_subnet" "db" {
  count = length(var.db_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-${count.index + 1}"
    Tier = "db"
  })
}

resource "aws_subnet" "dms" {
  count = length(var.dms_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.dms_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dms-${count.index + 1}"
    Tier = "dms"
  })
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Application security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Private app access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.onprem_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Private database access"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow database access from DMS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.onprem_cidr]
  }

  ingress {
    description = "Allow database access from app"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-sg"
  })
}

resource "aws_security_group" "dms" {
  name        = "${var.project_name}-${var.environment}-dms-sg"
  description = "DMS private replication access"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow source DB access from on-prem"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.onprem_cidr]
  }

  egress {
    from_port   = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dms-sg"
  })
}

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = aws_subnet.db[*].id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.onprem_cidr
    gateway_id = aws_vpn_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-rt"
  })
}

resource "aws_route_table" "dms" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.onprem_cidr
    gateway_id = aws_vpn_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dms-rt"
  })
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "dms" {
  count = length(aws_subnet.dms)

  subnet_id      = aws_subnet.dms[count.index].id
  route_table_id = aws_route_table.dms.id
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-rt"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.app[0].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-gw"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app.id
}

resource "aws_vpn_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vgw"
  })
}

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
