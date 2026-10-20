
variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "source_db_host" {
  type = string
}

variable "source_db_port" {
  type = number
}

variable "source_db_username" {
  type = string
}

variable "source_db_password" {
  type      = string
  sensitive = true
}

variable "source_db_name" {
  type = string
}

variable "target_db_host" {
  type = string
}

variable "target_db_name" {
  type = string
}

variable "target_db_username" {
  type = string
}

variable "target_db_password" {
  type      = string
  sensitive = true
}

variable "replication_instance_class" {
  type = string
}

variable "dms_engine_version" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
