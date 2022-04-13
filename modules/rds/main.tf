data "aws_subnet_ids" "sgb_private" {
  vpc_id = var.vpc_id
  tags = {
    tier = "private_subnet"
  }
}

data "aws_vpc" "sgb_selected" {
  id = var.vpc_id
}

data "aws_secretsmanager_secret_version" "sgb_db_creds" {
  secret_id = var.secret_id
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.sgb_db_creds.secret_string
  )
}

resource "aws_db_instance" "swarna-default" {
  identifier             = var.identifier
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = local.db_creds.username
  password               = local.db_creds.password
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.sgb-db-subnet.name
  vpc_security_group_ids = [aws_security_group.swarna-rds-sg.id]
  db_name                = var.dbname

}

data "aws_subnet_ids" "sgb-private" {
  vpc_id = var.vpc_id
  tags = {
    tier = "private_subnet"
  }
}
resource "aws_db_subnet_group" "sgb-db-subnet" {
  name       = "swarna-db-subnet-group"
  subnet_ids = tolist(data.aws_subnet_ids.sgb-private.ids)
}

resource "aws_security_group" "swarna-rds-sg" {
  vpc_id      = data.aws_vpc.sgb_selected.id
  description = "security group for RDS instances"
  ingress {
    description     = "RDS access from ec2"
    from_port       = var.mysql_port
    to_port         = var.mysql_port
    protocol        = var.tcp_protocol
    security_groups = ["${aws_security_group_sgb-pubec2sg.id}" ]

  }

  egress {
    from_port   = var.port_all
    to_port     = var.port_all
    protocol    = var.protocol_all
    cidr_blocks = [var.cidr_block]
  }
}
