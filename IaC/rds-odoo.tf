resource "aws_db_subnet_group" "subnet_bd" {
  name       = "example-db-subnet-group"
  subnet_ids = [module.vpc.database_subnets[0], module.vpc.database_subnets[1]]
}

resource "aws_db_instance" "postgres_odoo_1" {
  identifier             = "odoo-db-1"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "14.10"
  instance_class         = "db.t3.micro"
  username               = "odoo"
  password               = "MEisaPre2020++"
  db_subnet_group_name   = aws_db_subnet_group.subnet_bd.name
  multi_az               = false  
  availability_zone      = "us-east-1a"  
}

resource "aws_db_instance" "postgres_odoo_2" {
  identifier             = "odoo-db-2"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "14.10"
  instance_class         = "db.t3.micro"
  username               = "odoo"
  password               = "MEisaPre2020++"
  db_subnet_group_name   = aws_db_subnet_group.subnet_bd.name
  multi_az               = false  
  availability_zone      = "us-east-1b"  
}

output "db_address_1" {
  value = aws_db_instance.postgres_odoo_1.address
}

output "db_address_2" {
  value = aws_db_instance.postgres_odoo_2.address
}



