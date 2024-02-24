output "rds-url" {
  value = aws_db_instance.postgres_odoo.endpoint
}

output "primary_db_identifier" {
  value = aws_db_instance.postgres_odoo.identifier
}

output "db_address_1" {
  value = aws_db_instance.postgres_odoo.address
}