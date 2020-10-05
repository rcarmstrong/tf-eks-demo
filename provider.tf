provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}