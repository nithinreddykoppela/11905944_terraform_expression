provider "aws" {
  region  = "us-east-1"
}

variable "cidrs" {
    type = set(string)
  default = ["10.20.0.0/24" , "10.20.1.0/24"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name = "operators_vpc"
    "Environment" : "Dev"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  for_each = var.cidrs
  cidr_block = each.value
  tags = {
    Name = "operators_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "operators_routetable"
  }
}


locals {
  pub_sub_ids = toset([ for i in aws_subnet.public : i.id]) 
}

resource "aws_route_table_association" "a" {
  for_each       = local.pub_sub_ids 
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# output "public_subnets" {
#     value = [ for i in aws_subnet.public : i.id] 
# }



















