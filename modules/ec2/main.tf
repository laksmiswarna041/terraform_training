# Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "sgb-amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_subnet_ids" "sgb-public" {
  vpc_id = var.vpc_id

  tags = {
    tier = "public_subnet"
  }
}

resource "aws_key_pair" "swarna-tf2-rsa" {
  key_name = var.key_name
  public_key = var.public_key_value
}

# Public ec2 instances
resource "aws_instance" "sgb_ec2_public" {
  count                       = var.count_ec2
  ami                         = data.aws_ami.sgb-amazon-linux-2.id
  instance_type               = var.instance_type
  subnet_id                   = tolist(data.aws_subnet_ids.sgb-public.ids)[count.index]
  vpc_security_group_ids      = [aws_security_group.sgb-pubec2sg.id]
  key_name                    = aws_key_pair.swarna-tf2-rsa.key_name
  user_data = file("${path.module}/bootscript.sh")
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd git mariadb mariadb-server php php-mysql -y",
      "sudo systemctl httpd enable",
      "sudo service httpd start",
      "sudo chkconfig httpd on",
      "sudo systemctl restart httpd"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/swarna-tf2-rsa")
      host        = var.host
    }
  }
  provisioner "file" {
    source      = "/mysql-connection.php"
    destination = "/home/ec2-user/mysql-connection.php"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/swarna-tf2-rsa")
      host        = var.host
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /mysql-connection.php /var/www/html/mysql-connection.php"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/swarna-tf2-rsa")
      host        = var.host
    }
  }
  tags = {
    Name        = "${var.name_ec2}-${var.environment}-ec2-${count.index}"
    owner_name = var.owner_name
    mail_id=var.mail_id
  }
}

#ingress rules for instance
locals{
  ingress_rules = [{
    port = var.port_443
    description = "ingress rules for port 443"
  },
  {
    port = var.port_80
    description = "ingress rules for port  80"
  },
  {
    port = var.port_22
    description = "ingree rules for port 22"
  },
  {
    port = var.port_all
    description = "ingress rules for port all"
  }]
}

#security group for instance
resource "aws_security_group" "sgb-pubec2sg" {
  vpc_id      = var.vpc_id
  description = "sg for public instances"
  dynamic "ingress"{
    for_each = local.ingress_rules
    content{
      description = ingress.value.description
      port = ingress.value.port
      protocol = "tcp"
      cidr_blocks = [var.cidr_igw]
    }
  }

  egress {
    protocol    = var.protocol_all
    cidr_blocks = [var.igw_cidr]
    from_port   = var.port_all
    to_port     = var.port_all
  }  
  tags = {
    "Name" = "${var.environment}-sg-tf"
    owner_name = var.owner_name
    mail_id=var.mail_id
  }

}
