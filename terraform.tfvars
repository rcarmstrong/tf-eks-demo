# Project specific variables
project_name = "eks-demo"

# VPC CIDR Block Ranges
# 65,536 total IPs
vpc_block = "192.168.0.0/16"
# 16,384 IP addr block
public_subnet_01_block = "192.168.0.0/18"
# 16,384 IP addr block
public_subnet_02_block = "192.168.64.0/18"
# 16,384 IP addr block
private_subnet_01_block = "192.168.128.0/18"
# 16,384 IP addr block
private_subnet_02_block = "192.168.192.0/18"