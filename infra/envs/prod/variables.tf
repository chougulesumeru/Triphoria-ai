variable "rds_instance_class" {
  type = string
}

variable "backup_retension_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "db_password" {
  type      = string
  sensitive = true
}
