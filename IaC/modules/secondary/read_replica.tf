resource "aws_db_subnet_group" "secondary_subnet_bd" {
  name       = "rds-db-secondary-subnet-group"
  subnet_ids = [module.secondary_vpc.database_subnets[0], module.secondary_vpc.database_subnets[1]]
}

resource "aws_db_instance" "postgres_odoo_replica" {
  identifier           = "odoo-db-replica"
  replicate_source_db  = var.main_rds.arn
  db_subnet_group_name = aws_db_subnet_group.secondary_subnet_bd.name
  multi_az             = true
  instance_class       = "db.t3.micro"
  publicly_accessible  = false
  skip_final_snapshot  = true

  depends_on = [var.main_rds]

  tags = {
    Name        = "odoo-db-replica"
  }
}

output "db_replica_address" {
  value = aws_db_instance.postgres_odoo_replica.address
}