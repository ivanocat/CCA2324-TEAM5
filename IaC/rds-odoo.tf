resource "aws_db_subnet_group" "subnet_bd" {
  name       = "rds-db-subnet-group"
  subnet_ids = [module.vpc.database_subnets[0], module.vpc.database_subnets[1]]
}

resource "aws_security_group" "data_sg" {
  name        = "data-sg"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
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
  vpc_security_group_ids = [aws_security_group.data_sg.id]
  skip_final_snapshot    = true
}

output "db_address_1" {
  value = aws_db_instance.postgres_odoo.address
}