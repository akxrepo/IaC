resource "aws_eks_cluster" "eksdemo" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.tf-eks-cluster-role.arn
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
    # vpc_id = aws_vpc.EKS-TF-VPC-1.id
    subnet_ids = [
      aws_subnet.EKS-TF-SUB-PUB-1.id,
      aws_subnet.EKS-TF-SUB-PUB-2.id,
      aws_subnet.EKS-TF-SUB-PVT-PUB-1.id,
      aws_subnet.EKS-TF-SUB-PVT-PUB-2.id
    ]
    security_group_ids = [aws_security_group.EKS-TD-TF-SSH-HTTP.id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_addon" "eks-coredns" {
  cluster_name                = aws_eks_cluster.eksdemo.name
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  depends_on                  = [aws_eks_node_group.tf-eks-nodegroup-1]
}

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name    = aws_eks_cluster.eksdemo.name
#   addon_name      = "aws-ebs-csi-driver"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   depends_on = [ aws_eks_node_group.tf-eks-nodegroup-1 ]
# }

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name                = aws_eks_cluster.eksdemo.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.pod-identity-agent_version
  depends_on                  = [aws_eks_node_group.tf-eks-nodegroup-1]
}

resource "aws_eks_addon" "eks_external-dns" {
  cluster_name                = aws_eks_cluster.eksdemo.name
  addon_name                  = "external-dns"
  addon_version               = var.external-dns_version
  depends_on                  = [aws_eks_node_group.tf-eks-nodegroup-1]
  # service_account_role_arn = aws_iam_role.tf-eks-cluster-ext-dns-role.arn
}

resource "aws_eks_addon" "eks_kube-proxy" {
  cluster_name                = aws_eks_cluster.eksdemo.name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube-proxy_version
}

# resource "aws_eks_addon" "eks_metrics-server" {
#   cluster_name                = aws_eks_cluster.eksdemo.name
#   addon_name                  = "metrics-server"
#   addon_version               = var.metrics-server_version
#   resolve_conflicts_on_update = "PRESERVE"
#   depends_on = [ aws_eks_node_group.tf-eks-nodegroup-1 ]
# }

resource "aws_eks_addon" "eks_vpc-cni" {
  cluster_name                = aws_eks_cluster.eksdemo.name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc-cni_version
  # service_account_role_arn = aws_iam_role.tf-eks-cluster-vpc-cni-role.arn
}

resource "aws_eks_access_entry" "access_entry_root" {
  cluster_name  = aws_eks_cluster.eksdemo.name
  principal_arn = "arn:aws:iam::${local.account}:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_access" {
  cluster_name  = aws_eks_cluster.eksdemo.name
  principal_arn = "arn:aws:iam::${local.account}:root"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "access_entry_akmsn" {
  cluster_name  = aws_eks_cluster.eksdemo.name
  principal_arn = "arn:aws:iam::${local.account}:user/${local.user}"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin_access" {
  cluster_name  = aws_eks_cluster.eksdemo.name
  principal_arn = "arn:aws:iam::${local.account}:user/${local.user}"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# resource "aws_eks_identity_provider_config" "eks-oidc" {
#   cluster_name = aws_eks_cluster.eksdemo.name

#   oidc {
#     client_id                     = aws_eks_cluster.eksdemo.
#     identity_provider_config_name = "example"
#     issuer_url                    = "your issuer_url"
#   }
# }