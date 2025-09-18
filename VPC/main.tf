resource "aws_vpc" "optus-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "${local.project}-VPC"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id            = aws_vpc.optus-vpc.id
  for_each          = var.application2
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  
  tags = {
    Name = "${local.project}-SB-${each.key}"
    Type = "${each.value.type}"
  }
}

resource "aws_internet_gateway" "name-ig" {
  vpc_id = aws_vpc.optus-vpc.id
}

resource "aws_route" "public_internet_route" {
  route_table_id         = data.aws_route_table.name-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.name-ig.id
}

data "aws_subnets" "alb_subnets" {
  filter {
    name   = "tag:Type"
    values = ["ALB"]
  }

  filter {
    name   = "vpc-id"
    values = [aws_vpc.optus-vpc.id]  # Replace with your VPC resource or ID
  }
}

data "aws_subnet" "by_id" {
  for_each = toset(data.aws_subnets.alb_subnets.ids)
  id       = each.value
}
resource "aws_route_table_association" "alb_subnet_assoc" {
  for_each       = data.aws_subnet.by_id
  subnet_id      = each.value.id
  route_table_id = data.aws_route_table.name-rt.id
}