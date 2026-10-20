resource "aws_customer_gateway" "this" {
  bgp_asn    = 65000
  ip_address = var.customer_gateway_public_ip
  type       = "ipsec.1"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-customer-gateway"
  })
}

resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpn-gateway"
  })
}

resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_ike_versions {
    ike_versions = [var.vpn_ike_version]
  }

  tunnel1_phase1_lifetime_seconds = var.vpn_lifetime
  tunnel1_phase1_encryption_algorithms {
    encryption_algorithms = [var.vpn_encryption_algorithm]
  }
  tunnel1_phase1_integrity_algorithms {
    integrity_algorithms = [var.vpn_integrity_algorithm]
  }
  tunnel1_phase1_dh_group_numbers {
    dh_group_numbers = [lookup({
      "group2"  = 2,
      "group14" = 14,
      "group16" = 16
    }, var.vpn_dh_group)]
  }
  tunnel1_phase1_dh_group_numbers {
    dh_group_numbers = [lookup({
      "group2"  = 2,
      "group14" = 14,
      "group16" = 16
    }, var.vpn_dh_group)]
  }

  tunnel1_phase2_lifetime_seconds = var.vpn_lifetime
  tunnel1_phase2_encryption_algorithms {
    encryption_algorithms = [var.vpn_encryption_algorithm]
  }
  tunnel1_phase2_integrity_algorithms {
    integrity_algorithms = [var.vpn_integrity_algorithm]
  }
  tunnel1_phase2_dh_group_numbers {
    dh_group_numbers = [lookup({
      "group2"  = 2,
      "group14" = 14,
      "group16" = 16
    }, var.vpn_dh_group)]
  }

  tunnel1_perfect_forward_secrecy {
    perfect_forward_secrecy = var.vpn_pfs
  }

  tunnel2_ike_versions {
    ike_versions = [var.vpn_ike_version]
  }

  tunnel2_phase1_lifetime_seconds = var.vpn_lifetime
  tunnel2_phase2_lifetime_seconds = var.vpn_lifetime
  tunnel2_phase1_encryption_algorithms {
    encryption_algorithms = [var.vpn_encryption_algorithm]
  }
  tunnel2_phase1_integrity_algorithms {
    integrity_algorithms = [var.vpn_integrity_algorithm]
  }
  tunnel2_phase1_dh_group_numbers {
    dh_group_numbers = [lookup({
      "group2"  = 2,
      "group14" = 14,
      "group16" = 16
    }, var.vpn_dh_group)]
  }

  tunnel2_phase2_encryption_algorithms {
    encryption_algorithms = [var.vpn_encryption_algorithm]
  }

  tunnel2_phase2_integrity_algorithms {
    integrity_algorithms = [var.vpn_integrity_algorithm]
  }

  tunnel2_phase2_dh_group_numbers {
    dh_group_numbers = [lookup({
      "group2"  = 2,
      "group14" = 14,
      "group16" = 16
    }, var.vpn_dh_group)]
  }

  tunnel2_perfect_forward_secrecy {
    perfect_forward_secrecy = var.vpn_pfs
  }

  static_routes = [
    var.onprem_cidr
  ]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpn"
  })
}

resource "aws_vpn_connection_route" "onprem" {
  count = 1

  destination_cidr_block = var.onprem_cidr
  vpn_connection_id      = aws_vpn_connection.this.id
}

output "vpn_connection_id" {
  value = aws_vpn_connection.this.id
}

output "tunnel1_ip" {
  value = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_ip" {
  value = aws_vpn_connection.this.tunnel2_address
}
