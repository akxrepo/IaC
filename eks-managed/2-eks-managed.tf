# IAM Roles and Policies for EKS Cluster and Nodes
resource "aws_iam_role" "cluster_iam_role" {
    name = "AmazonEKSMGDClusterRole"
    
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
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ])
    role       = aws_iam_role.cluster_iam_role.name
    policy_arn = each.value
}

resource "aws_iam_role" "node_iam_role" {
    name = "AmazonEKSMGDNodeRole"
    
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
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ])
    role       = aws_iam_role.node_iam_role.name
    policy_arn = each.value
}


resource "aws_iam_policy" "karpenter_passrole" {
  name        = "KarpenterPassNodeRole"
  description = "Allow Karpenter to pass the EKS node role"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": aws_iam_role.node_iam_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_passrole_attach" {
  role       = "eks-mgd-karpenter-role" # The controller role
  policy_arn = aws_iam_policy.karpenter_passrole.arn
}

# EKS Cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.cluster_iam_role.arn
  version  = var.eks_version

  upgrade_policy {
    support_type = "STANDARD"
  } 

  # Cluster authentication mode
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"  # matches "EKS API and ConfigMap"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = data.aws_subnets.pvt_subnets.ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.node_iam_role.arn
  subnet_ids      = data.aws_subnets.pvt_subnets.ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # instance_types = ["c7i-flex.large"] #
  # capacity_type =  "ON_DEMAND" #"SPOT" #
   instance_types = var.instance_type  # Use a more common instance type
   capacity_type  = var.capacity_type
   ami_type       = var.eks_ami   # Let AWS choose the AMI


  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
  ]
}

# Launch Template for EKS Nodes
resource "aws_launch_template" "eks_node_launch_template" {
  name_prefix   = "eks-${var.environment}-node-"
  #image_id      = "ami-0329ac7d12d171324" # EKS optimized AMI for version 1.32 in us-east-1
  #image_id      = "ami-0767f1fe1d85e096f" # EKS optimized AMI for version 1.33 in us-east-1

  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"   # Root device
    ebs {
      volume_size           = 20        # Disk size in GiB
      volume_type           = "gp3"     # gp2, gp3, io1, etc.
      delete_on_termination = true
      encrypted             = true
    }
  }
  
  # spot_options {
  #   instance_interruption_behavior = "terminate"
  #   max_price                      = "0.0736"  # Set your max price for spot instances
  #   spot_instance_type             = "one-time"
  # }
  

  # user_data = base64encode(<<-EOF
  #             #!/bin/bash
  #             set -o xtrace
  #             /etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name} --kubelet-extra-args '--node-labels=role=worker-node'
  #             EOF
  #           )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "EKS-${var.environment}-Node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Essential Add-ons
resource "aws_eks_addon" "essential_addons" {
  for_each = {
    vpc_cni = {
      addon_name    = "vpc-cni"
      addon_version = var.vpc-cni_version
    }
    coredns = {
      addon_name    = "coredns" 
      addon_version = var.coredns_version
    }
    kube_proxy = {
      addon_name    = "kube-proxy"
      addon_version = var.kube-proxy_version
    }
    metrics_server = {
      addon_name    = "metrics-server"
      addon_version = var.metrics-server_version
    }
    pod_identity_agent = {
      addon_name    = "eks-pod-identity-agent"
      addon_version = var.pod-identity-agent_version
    }
    ebs_csi_driver = {
      addon_name    = "aws-ebs-csi-driver"
      addon_version = var.ebs_csi_driver_version
    }
    # aws_load_balancer_controller = {
    #   addon_name    = "aws-load-balancer-controller"
    #   addon_version = "v2.8.2-eksbuild.1"
    # }
  }
  
  cluster_name                    = aws_eks_cluster.eks_cluster.name
  addon_name                     = each.value.addon_name
  addon_version                  = each.value.addon_version
  resolve_conflicts_on_create    = "OVERWRITE"
  resolve_conflicts_on_update    = "OVERWRITE"
  
  depends_on = [aws_eks_node_group.eks_node_group]
}




# Security Groups for EKS
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "eks-${var.environment}-cluster-sg-"
  vpc_id      = aws_vpc.test-vpc.id

  dynamic "ingress" {
    for_each = toset([80, 443])
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
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
    Name = "eks-${var.environment}-cluster-sg"
  }
}

resource "aws_security_group" "eks_node_sg" {
  name_prefix = "eks-${var.environment}-node-sg-"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  dynamic "ingress" {
    for_each = toset([80, 443])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.test-vpc.cidr_block]
    }
  }

  dynamic "ingress" {
    for_each = toset([80, 443])
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.eks_cluster_sg.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-${var.environment}-node-sg"
    "karpenter.sh/discovery" = var.eks_cluster_name
  }
}

# Create Additional Access Entry to EKS Cluster
# resource "aws_eks_access_entry" "eks_cluster_access_entry" {
#   cluster_name = aws_eks_cluster.eks_cluster.name
#   entry_type   = "ADMIN"
#   principal_arn = var.admin_arn  # Replace with your IAM user or role ARN

#   depends_on = [
#     aws_eks_cluster.eks_cluster
#   ]
  
# }


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

  depends_on = [ aws_subnet.test-subnet-pub-1, aws_subnet.test-subnet-pub-2 ]
}

data "aws_subnets" "pvt_subnets" {
  filter {
    name   = "tag:Type"
    values = ["Private"]
  } 
  filter {
      name   = "vpc-id"
      values = [aws_vpc.test-vpc.id]  # Replace with your VPC resource or ID
  }

  depends_on = [ aws_subnet.test-subnet-pvt-1, aws_subnet.test-subnet-pvt-2 ]
}