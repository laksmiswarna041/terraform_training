variable "vpc_id" {
    description = "vpc id"
    type = string  
}

variable "public_security_group_id" {
  description = "public ec2 instances security group id"
  type = any
}

variable "identifier" {
  description = "identifier of the database"
  type = any 
}

variable "dbname" {
  description = "name of the database"
  type = any
}
variable "secret_id"{
  description = "name of secrets store"
  type = any

}
variable "port_all" {
  description = "port 0"
  default = 0
}
variable "protocol_all" {
  description = "All protocols"
  default = "-1"
}
variable "cidr_block" {
  description = "cidr_block"
  default = "0.0.0.0/0"
}
variable "engine" {
  description = "engine"
  default = "mysql"
}
variable "allocated_storage" {
  description = "allocated_storage"
  default = 10
}
variable "engine_version" {
  description = "engine_version"
 default = "5.7" 
}
variable "instance_class" {
  description = "instance_class"
  default = "db.t2.micro"
}
variable "parameter_group_name" {
  description = "parameter_group_name"
  default = "default.mysql5.7"
}
variable "mysql_port" {
  description ="mysql_port" 
  default = 3306
}
variable "tcp_protocol" {
  description = "tcp_protocol"
 default = "tcp" 
}