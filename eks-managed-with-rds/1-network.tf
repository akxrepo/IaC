resource "aws_vpc" "test-vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support   = true 
  enable_dns_hostnames = true
  tags = {
    Name = "EKS-${var.environment}-VPC"
  }
}

resource "aws_subnet" "test-subnet-pub-1" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "EKS-${var.environment}-Public-Subnet-1"
    Type = "Public"
    "kubernetes.io/role/elb" = "1"  # Required for public load balancers
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"  # EKS discovery
  }
}

resource "aws_subnet" "test-subnet-pub-2" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
    tags = {
        Name = "EKS-${var.environment}-Public-Subnet-2"
        Type = "Public"
        "kubernetes.io/role/elb" = "1"  # Required for public load balancers
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"  # EKS discovery
    }
}

resource "aws_subnet" "test-subnet-pvt-1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
    tags = {
        Name = "EKS-${var.environment}-Private-Subnet-1"
        Type = "Private"
        "karpenter.sh/discovery" = var.eks_cluster_name
    }
}

resource "aws_subnet" "test-subnet-pvt-2" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = false
    tags = {
        Name = "EKS-${var.environment}-Private-Subnet-2"
        Type = "Private"
        "karpenter.sh/discovery" = var.eks_cluster_name
    }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id
    tags = {
        Name = "EKS-${var.environment}-IGW"
    }
}

resource "aws_eip" "nat-eip" {
    tags = {
        Name = "EKS-${var.environment}-NAT-EIP"
    }
}

resource "aws_nat_gateway" "test-natgw" {
  allocation_id = aws_eip.nat-eip.allocation_id
  subnet_id     = aws_subnet.test-subnet-pub-1.id
    tags = {
        Name = "EKS-${var.environment}-NAT-GW"
    }
  depends_on = [aws_internet_gateway.test-igw]
  
}

resource "aws_route_table" "test-rt-pub" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }
    tags = {
        Name = "EKS-${var.environment}-Public-RT"
    }
}

resource "aws_route_table" "test-rt-pvt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test-natgw.id
    }
    tags = {
        Name = "EKS-${var.environment}-Private-RT"
    }
}

resource "aws_route_table_association" "pub-rt-pub-assoc" {
  for_each = {
    pub1 = aws_subnet.test-subnet-pub-1.id
    pub2 = aws_subnet.test-subnet-pub-2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.test-rt-pub.id
}

resource "aws_route_table_association" "pvt-rt-pvt-assoc" {
  for_each = {
    pvt1 = aws_subnet.test-subnet-pvt-1.id 
    pvt2 = aws_subnet.test-subnet-pvt-2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.test-rt-pvt.id 
}

resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP, HTTPS traffic"
  vpc_id      = aws_vpc.test-vpc.id

  dynamic "ingress" {
    for_each = toset([80, 443])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "EKS-${var.environment}-alb-SG"
    }
}

resource "aws_security_group" "alb-to-ec2-sg" {
  name        = "alb-to-ec2-sg"
  description = "Allow HTTP, HTTPS traffic"
  vpc_id      = aws_vpc.test-vpc.id

  dynamic "ingress" {
    for_each = toset([80, 443])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      #cidr_blocks = ["10.1.0.0/16"]
      security_groups = [aws_security_group.alb-sg.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "EKS-${var.environment}-alb-to-ec2-sg"
    }
}


resource "aws_security_group" "allow-all-sg" {
  name        = "allow-all-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS-${var.environment}-allow-all-sg"
  }
}
