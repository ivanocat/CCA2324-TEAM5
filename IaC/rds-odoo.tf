resource "aws_db_subnet_group" "subnet_bd" {
  name       = "rds-db-subnet-group"
  subnet_ids = [module.vpc.database_subnets[0], module.vpc.database_subnets[1]]
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
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
  vpc_security_group_ids = [module.data_sg.security_group_id]
  skip_final_snapshot    = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "Team 5"
    Project     = "CCA2324-PFP"
  }
}

output "db_address_1" {
  value = aws_db_instance.postgres_odoo.address
}