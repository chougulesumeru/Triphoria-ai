# configure varibales for ecs
variable "env_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "db_endpoint" {
  type = string
}
