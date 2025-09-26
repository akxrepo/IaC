#################################
# IAM Roles & Policies
#################################

resource "aws_iam_role" "cluster_iam_role" {
  name = "AmazonEKSAutoClusterRole"
    
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "EKS-${var.environment}-Cluster-Role"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  ])
  role       = aws_iam_role.cluster_iam_role.name
  policy_arn = each.value
}

#################################
# EKS Auto Mode Node Group IAM Role
#################################

resource "aws_iam_role" "node_group_role" {
  name = "AmazonEKSAutoNodeRole"
    
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "EKS-${var.environment}-Node-Role"
  }
}

resource "aws_iam_role_policy_attachment" "node_group_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  ])
  role       = aws_iam_role.node_group_role.name
  policy_arn = each.value
}


#################################
# Data Sources (VPC/Subnets)
#################################

data "aws_subnets" "pvt_subnets" {
  filter {
    name   = "tag:Type"
    values = ["Private"]
  } 
  filter {
    name   = "vpc-id"
    values = [aws_vpc.test-vpc.id]
  }

  depends_on = [
    aws_subnet.test-subnet-pvt-1,
    aws_subnet.test-subnet-pvt-2
  ]
}

#################################
# EKS Auto Mode Cluster
#################################

resource "aws_eks_cluster" "eks_auto_cluster" {
  name     = var.eks_cluster_name
  version  = var.eks_version
  role_arn = aws_iam_role.cluster_iam_role.arn

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = data.aws_subnets.pvt_subnets.ids
  }

  bootstrap_self_managed_addons = false

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  compute_config {
    enabled    = true
    node_pools = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.node_group_role.arn  
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  tags = {
    Name        = var.eks_cluster_name
    Environment = "development"
    Type        = "EKS-${var.environment}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policies
  ]
}