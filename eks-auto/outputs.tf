output "eks_auto_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "alb_subnets" {
  description = "The IDs of the ALB subnets"
  value       = data.aws_subnets.alb_subnets.ids
}