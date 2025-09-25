output "eks_auto_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_auto_cluster.name
}

# output "alb_subnets" {
#   description = "The IDs of the ALB subnets"
#   value       = data.aws_subnets.alb_subnets.ids
# }

# output "oidc_issuer_url" {
#   description = "The OIDC issuer URL for the EKS cluster"
#   value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }