variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "customer_gateway_public_ip" {
  type = string
}

variable "onprem_cidr" {
  type = string
}

variable "vpn_tunnel_inside_cidr_1" {
  type = string
}

variable "vpn_tunnel_inside_cidr_2" {
  type = string
}

variable "vpn_ike_version" {
  type = string
}

variable "vpn_dh_group" {
  type = string
}

variable "vpn_encryption_algorithm" {
  type = string
}

variable "vpn_integrity_algorithm" {
  type = string
}

variable "vpn_lifetime" {
  type = number
}

variable "vpn_pfs" {
  type = string
}

variable "tags" {
  type = map(string)
}
