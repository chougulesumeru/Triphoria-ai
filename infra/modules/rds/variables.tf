variable "identifier" {
  type = string
}

variable "engine" {
  default = "postgres"
  type    = string
}

variable "engine_version" {
  default = "16.3"
  type    = string
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "backup_retension_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "multi_az" {
  type    = bool
  default = false
}
