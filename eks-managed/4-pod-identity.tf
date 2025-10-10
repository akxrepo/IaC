resource "aws_eks_pod_identity_association" "karpenter_pod_identity" {
  for_each = {
    karpenter = {
      pod_name       = "karpenter"
      namespace      = "karpenter"
      service_account_name = "karpenter"
      oidc_provider_arn   = aws_iam_openid_connect_provider.eks_oidc_provider.arn
      role_arn            = aws_iam_role.karpenter_role.arn
    }
  }
  
  namespace             = each.value.namespace
  service_account       = each.value.service_account_name
  role_arn              = each.value.role_arn
  cluster_name = var.eks_cluster_name

  depends_on = [aws_eks_addon.essential_addons]
  
}