# Project Name
variable "project_name" {
  type = string
}

# CIDR range for entire VPC
variable "vpc_block" {
  type = string
}

# CIDR range for public subnet 01
variable "public_subnet_01_block" {
  type = string
}

# CIDR range for public subnet 02
variable "public_subnet_02_block" {
  type = string
}

# CIDR range for private subnet 01
variable "private_subnet_01_block" {
  type = string
}

# CIDR range for private subnet 02
variable "private_subnet_02_block" {
  type = string
}