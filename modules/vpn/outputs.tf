output "vpn_connection_id" {
  value = aws_vpn_connection.this.id
}

output "tunnel1_ip" {
  value = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_ip" {
  value = aws_vpn_connection.this.tunnel2_address
}
