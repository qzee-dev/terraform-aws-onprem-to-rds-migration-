variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "costcenter" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "app_subnet_cidrs" {
  type = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}

variable "dms_subnet_cidrs" {
  type = list(string)
}

variable "onprem_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
