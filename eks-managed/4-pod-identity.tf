resource "aws_iam_role" "karpenter_role" {
  name = "eks-${var.environment}-karpenter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name = "eks-${var.environment}-karpenter-controller-role"
  }
}

resource "aws_iam_policy" "karpenter_policy" {
  name        = "eks-${var.environment}-karpenter-controller-policy"
  description = "IAM policy for Karpenter"
  policy      = file("karpenter-controller-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "karpenter_attach_policy" {
  role       = aws_iam_role.karpenter_role.name
  policy_arn = aws_iam_policy.karpenter_policy.arn
}

resource "aws_eks_pod_identity_association" "karpenter_pod_identity" {
  for_each = {
    karpenter = {
      namespace            = "karpenter"
      service_account_name = "karpenter"
      role_arn             = aws_iam_role.karpenter_role.arn
    }
  }

  namespace       = each.value.namespace
  service_account = each.value.service_account_name
  role_arn        = each.value.role_arn
  cluster_name    = var.eks_cluster_name

  depends_on = [aws_eks_addon.essential_addons]
}