resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd9e7c6"] # Amazon's OIDC thumbprint
  url             = aws_eks_cluster.eks_auto_cluster.identity[0].oidc[0].issuer
  
  depends_on = [aws_eks_cluster.eks_auto_cluster]
  tags = {
    Name = "EKS-Auto-OIDC-Provider"
    EKS-Cluster = var.eks_cluster_name
  }
}

# IAM Policy 
resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for the AWS Load Balancer Controller"
  policy      = file("alb-iam-policy.json")
  
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": aws_iam_openid_connect_provider.eks-oidc-provider.arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${replace(aws_eks_cluster.eks_auto_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  
  tags = {
    Name = "EKS-Auto-ALB-Controller-Role"
    EKS-Cluster = var.eks_cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "attach_load_balancer_controller_policy" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}