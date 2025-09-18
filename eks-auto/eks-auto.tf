resource "aws_iam_role" "cluster_iam_role" {
    name = "AmazonEKSAutoClusterRole"
    
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
  ])
    role       = aws_iam_role.cluster_iam_role.name
    policy_arn = each.value
}

resource "aws_iam_role" "node_iam_role" {
    name = "AmazonEKSAutoNodeRole"
    
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
    for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  ])
    role       = aws_iam_role.node_iam_role.name
    policy_arn = each.value
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-auto-cluster"
  role_arn = aws_iam_role.cluster_iam_role.arn
  version  = "1.32"

  vpc_config {
    subnet_ids = data.aws_subnets.alb_subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}


####################
# Data Sources
####################

data "aws_subnets" "alb_subnets" {
  filter {
    name   = "tag:Type"
    values = ["Public"]
  } 
  filter {
      name   = "vpc-id"
      values = [aws_vpc.test-vpc.id]  # Replace with your VPC resource or ID
  }
}