# configure rds outputs.tf 

output "endpoint" {
  value = aws_db_instance.rds_main.endpoint
}
