# configure remote state management for dev env
terraform {
  backend "s3" {
    bucket = "terra-state-dev"
    key    = "prod/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "network" {
  source              = "../../modules/network"
  env_name            = "dev"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  azs                 = ["us-east-2a", "us-east-2b"]
}

resource "aws_security_group" "alb_sg" {
  name   = "dev-alb-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ecs_sg" {
  name   = "dev-ecs-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "dev-rds-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

module "rds" {
  source                  = "../../modules/rds"
  identifier              = "dev-db"
  instance_class          = var.rds_instance_class
  allocated_storage       = 20
  db_name                 = "app"
  username                = "appuser"
  password                = var.db_password
  subnet_ids              = module.network.private_subnet_ids
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  backup_retension_period = var.backup_retension_period
  deletion_protection     = var.deletion_protection
}

module "ecs" {
  source             = "../../modules/ecs"
  env_name           = "dev"
  container_image    = "nginx:latest"
  cpu                = "256"
  memory             = "512"
  desired_count      = 2
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = aws_security_group.alb_sg.id
  ecs_sg_id          = aws_security_group.ecs_sg.id
  db_endpoint        = module.rds.endpoint
}
