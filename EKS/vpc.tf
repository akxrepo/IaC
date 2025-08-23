# Create VPC
resource "aws_vpc" "EKS-TF-VPC-1" {
    cidr_block = "10.7.0.0/16"
    instance_tenancy = "default"
    tags = {
      Name = "EKS-VPC"
      AK = "Terraform"
      Terraform = "true"
    }
}

#Create Subnets
resource "aws_subnet" "EKS-TF-SUB-PUB-1" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  cidr_block = "10.7.1.0/24"
  availability_zone = var.spot_az1
  map_public_ip_on_launch = true
  tags = {
      Name = "EKS-VPC-SUB-PUB-1"
      AK = "Terraform"
      Terraform = "true"
      "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "EKS-TF-SUB-PUB-2" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  cidr_block = "10.7.2.0/24"
  availability_zone = var.spot_az2
  map_public_ip_on_launch = true
  tags = {
      Name = "EKS-VPC-SUB-PUB-2"
      AK = "Terraform"
      Terraform = "true"
      "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "EKS-TF-SUB-PVT-PUB-1" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  cidr_block = "10.7.3.0/24"
  availability_zone = var.spot_az1
  map_public_ip_on_launch = true
  tags = {
      Name = "EKS-VPC-SUB-PVT-PUB-1"
      AK = "Terraform"
      Terraform = "true"
      #"kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "EKS-TF-SUB-PVT-PUB-2" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  cidr_block = "10.7.4.0/24"
  availability_zone = var.spot_az2
  map_public_ip_on_launch = true
  tags = {
      Name = "EKS-VPC-SUB-PVT-PUB-2"
      AK = "Terraform"
      Terraform = "true"
      #"kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "EKS-TF-SUB-PVT-1" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  cidr_block = "10.7.5.0/24"
  availability_zone = var.spot_az1
  map_public_ip_on_launch = true
  tags = {
      Name = "EKS-VPC-SUB-PVT1"
      AK = "Terraform"
      Terraform = "true"
      #"kubernetes.io/role/internal-elb" = 1
    }
}

resource "aws_subnet" "EKS-TF-SUB-PVT-2" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  cidr_block = "10.7.6.0/24"
  availability_zone = var.spot_az2
  map_public_ip_on_launch = true
  tags = {
      Name = "EKS-VPC-SUB-PVT2"
      AK = "Terraform"
      Terraform = "true"
      #"kubernetes.io/role/internal-elb" = 1
    }
}

#Create Internet Gateway
resource "aws_internet_gateway" "EKS-TF-IG-1" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  tags = {
      Name = "EKS-VPC-IG"
      AK = "Terraform"
      Terraform = "true"
    }
}

# Public Route Table
resource "aws_route_table" "EKS-TF-RT-PUB-1" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EKS-TF-IG-1.id
  }
  tags = {
      Name = "EKS-RT-PUB1"
      AK = "Terraform"
      Terraform = "true"
    }
}

# Route Table Subnet Association
resource "aws_main_route_table_association" "EKS-TF-RT-SUB-PUB-1" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  route_table_id = aws_route_table.EKS-TF-RT-PUB-1.id
}

resource "aws_route_table_association" "EKS-TF-RT-SUB-PUB1" {
  subnet_id = aws_subnet.EKS-TF-SUB-PUB-1.id
  route_table_id = aws_route_table.EKS-TF-RT-PUB-1.id
}

resource "aws_route_table_association" "EKS-TF-RT-SUB-PUB2" {
  subnet_id = aws_subnet.EKS-TF-SUB-PUB-2.id
  route_table_id = aws_route_table.EKS-TF-RT-PUB-1.id
}

resource "aws_route_table_association" "EKS-TF-RT-SUB-PVT-PUB1" {
  subnet_id = aws_subnet.EKS-TF-SUB-PVT-PUB-1.id
  route_table_id = aws_route_table.EKS-TF-RT-PUB-1.id
}

resource "aws_route_table_association" "EKS-TF-RT-SUB-PVT-PUB2" {
  subnet_id = aws_subnet.EKS-TF-SUB-PVT-PUB-2.id
  route_table_id = aws_route_table.EKS-TF-RT-PUB-1.id
}

#Create Key Pair
resource "aws_key_pair" "akloud" {
  key_name = "akloud"
  public_key = var.aws_keys
}

#Create Security Group
resource "aws_security_group" "EKS-TD-TF-SSH-HTTP" {
  vpc_id = aws_vpc.EKS-TF-VPC-1.id
  name = "EKS-TD-TF-SSH-HTTP"
  lifecycle {
    create_before_destroy = true
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
      Name = "EKS-TD-TF-SSH-HTTP"
      AK = "Terraform"
      Terraform = "true"
    }
}

resource "aws_security_group_rule" "eks-ingress_rules1" {
  for_each          = var.ingress_ports
  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.EKS-TD-TF-SSH-HTTP.id
  description       = "Port ${each.value}"
}

resource "aws_security_group_rule" "eks-ingress_rules2" {
  for_each          = var.ingress_ports_node_port
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.EKS-TD-TF-SSH-HTTP.id
  description       = "Port ${each.value.from_port} - ${each.value.to_port}"
}