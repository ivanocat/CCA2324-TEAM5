resource "aws_db_subnet_group" "subnet_bd" {
  name       = "rds-db-subnet-group"
  subnet_ids = var.database_subnets
}

resource "aws_db_instance" "postgres_odoo_replica" {
  identifier               = "odoo-db-replica"
  replicate_source_db      = var.db_source_indentifier
  db_subnet_group_name     = aws_db_subnet_group.subnet_bd.name
  multi_az                 = true
  instance_class           = "db.t3.micro"
  publicly_accessible      = false
  skip_final_snapshot      = true

  tags = {
    Name        = "odoo-db-replica"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}