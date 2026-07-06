# configure rds main.tf

resource "aws_db_subnet_group" "rds_main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "rds_main" {
  identifier              = var.identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.rds_main.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  publicly_accessible     = false
  backup_retention_period = var.backup_retension_period
  deletion_protection     = var.deletion_protection
  multi_az                = var.multi_az
  skip_final_snapshot     = true
}