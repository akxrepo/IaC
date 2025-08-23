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