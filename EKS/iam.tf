# Step1: Create Cluster IAM Role
resource "aws_iam_role" "tf-eks-cluster-role" {
  name = "tf-eks-cluster-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
        ]
    })

  tags = {
    Terraform = "true"
  }
}

# Step2: Attach AmazonEKSClusterPolicy policy to Cluster IAM Role created in 
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.tf-eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Roles for 2 Add-ons
# Add-on1: VPC CNI
resource "aws_iam_role" "tf-eks-cluster-vpc-cni-role" {
  name = "tf-eks-cluster-vpc-cni-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "pods.eks.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
})

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.tf-eks-cluster-vpc-cni-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Add-on2: External DNS
resource "aws_iam_role" "tf-eks-cluster-ext-dns-role" {
  name = "tf-eks-cluster-ext-dns-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "pods.eks.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
})

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonRoute53FullAccess" {
  role       = aws_iam_role.tf-eks-cluster-ext-dns-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

# IAM Policy for NodeGroup
resource "aws_iam_role" "tf-eks-cluster-node-group-role" {
  name = "tf-eks-cluster-node-group-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
})

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "EKS-NodeGroup" {
  role       = aws_iam_role.tf-eks-cluster-node-group-role.name
  for_each = toset(var.nodegroup_policy)
  policy_arn = each.value
}