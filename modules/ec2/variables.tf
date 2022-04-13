variable "environment" {
  description = "Deployment Environment"
  type = any
}
variable "count_ec2" {
  description = "count of ec2 instances"
  type = any 
}
variable "ami"{
  description = "image of ec2 instances"
  type = any
}
variable "key_name" {
  description = "key name for ec2 instances"
  type = string
}
variable "public_key_value" {
  description = "key value for ec2 instances"
  type = string
}
variable "vpc_id" {
  description = "vpc id"
  type = string  
}
variable "instance_type" {
  description = "ec2 instance type"
  type = string  
}
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
  type = any
}
variable "owner_name" {
  description = "resource owner"
  type        = string
}
variable "mail_id" {
  description = "owner mail id"
  type        = string
}
variable "name_ec2"{
  description = "ec2 instance name"
  type = any
}
variable "port_80" {
  description = "port 80"
  type = any
}
variable "port_all" {
  description = "port all"
  type = any
}
variable "protocol_all" {
  description = "protocol all"
  type = any
}
variable "ssh_port" {
  description = "ssh_port"
  type = any
}
variable "tcp_protocol" {
  description = "tcp_protocol"
  type = any
}
variable "igw_cidr" {
  description = "igw_cidr"
  type = any
}
variable "port_443" {
  description = "port_443"
  type = any
}
variable "private_key" {
  description = "private key file"
  type = any
}
variable "host" {
  type = string
  description = "DB host value"
}