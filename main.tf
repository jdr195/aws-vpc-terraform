terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.0"
    }
  }
  required_version = ">= 1.7.4"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    var.tags,
    {
      Name = "Terraform"
    },
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Terraform"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  tags = merge(
    var.tags,
    {
      Name = "Terraform Public Subnet ${count.index + 1}"
    }
  )
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  tags = merge(
    var.tags,
    {
      Name = "Terraform Private Subnet ${count.index + 1}"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(
    var.tags,
    {
      Name = "Terraform Public Route Table"
    }
  )
}

resource "aws_route_table_association" "public_subnet_route_table_assocation" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_gateways" {
  count = length(var.private_subnet_cidrs)
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = element(aws_eip.nat_gateways[*].id, count.index)
  subnet_id     = element(aws_subnet.private_subnets[*].id, count.index)

  tags = merge(
    var.tags,
    {
      Name = "Terraform Nat Gateway ${count.index + 1}"
    }
  )


  depends_on = [aws_internet_gateway.gw, aws_eip.nat_gateways]
}

resource "aws_route_table" "private_route_tables" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateways[*].id, count.index)
  }

  tags = merge(
    var.tags,
    {
      Name = "Terraform Private Route Table ${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "private_subnet_route_table_assocations" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_route_tables[*].id, count.index)
}