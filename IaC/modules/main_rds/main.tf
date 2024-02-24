resource "aws_db_subnet_group" "subnet_bd" {
  name       = "rds-db-subnet-group"
  subnet_ids = var.database_subnets
}

resource "aws_db_instance" "postgres_odoo" {
  identifier             = "odoo-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15.5"
  instance_class         = "db.t3.micro"
  username               = "odoo"
  password               = "MEisaPre2020++"
  db_subnet_group_name   = aws_db_subnet_group.subnet_bd.name
  multi_az               = true   
  vpc_security_group_ids = var.data_sg_id
  skip_final_snapshot    = true
}