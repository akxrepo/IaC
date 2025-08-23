# # # Step 1: Create IAM Policy
# # resource "aws_iam_policy" "aws_load_balancer_controller" {
# #   name        = "AWSLoadBalancerControllerIAMPolicy"
# #   description = "IAM policy for AWS Load Balancer Controller"
# #   policy      = file("iam-policy.json")  # download from AWS documentation
# # }

# # Step 2: Create OIDC Provider
# data "aws_eks_cluster" "cluster" {
#   name = var.eks_cluster_name
#   depends_on = [ aws_eks_cluster.eksdemo ]
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = var.eks_cluster_name
#   depends_on = [ aws_eks_cluster.eksdemo ]
# }

# resource "aws_iam_openid_connect_provider" "oidc" {
#   client_id_list  = ["sts.amazonaws.com"]
#   # thumbprint_list = [data.aws_eks_cluster.cluster.certificate_authority[0].data] # 
#   thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0cbdcc3ef"]
#   url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   depends_on = [ aws_eks_cluster.eksdemo ]
# }

# # Step 3: Create IAM Role with Trust Policy for ServiceAccount
# resource "aws_iam_role" "aws_lb_controller_irsa" {
#   name = "eks-lb-controller-irsa-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.oidc.arn
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Condition = {
#           StringEquals = {
#             "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }
#       }
#     ]
#   })
#   depends_on = [ aws_eks_cluster.eksdemo ]
# }

# # Step 4: Attach IAM Policy to Role
# data "aws_iam_policy" "aws_lb" {
#   arn = "arn:aws:iam::635920908129:policy/AWSLoadBalancerControllerIAMPolicy"
# }

# resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerIAMPolicy" {
#   role       = aws_iam_role.aws_lb_controller_irsa.name
#   policy_arn = "arn:aws:iam::635920908129:policy/AWSLoadBalancerControllerIAMPolicy"
# }

# # Step 5: Create the Kubernetes Service Account
# # provider "kubernetes" {
# #   host                   = data.aws_eks_cluster.cluster.endpoint
# #   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
# #   token                  = data.aws_eks_cluster_auth.cluster.token
# # }

# # resource "kubernetes_service_account" "aws_lb_controller" {
# #   metadata {
# #     name      = var.lb_controller_sa_name
# #     namespace = "kube-system"
# #     annotations = {
# #       "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_irsa.arn
# #     }
# #   }
# #   depends_on = [ aws_eks_node_group.tf-eks-nodegroup-1,
# #                  aws_internet_gateway.EKS-TF-IG-1,
# #                  aws_eks_access_entry.access_entry_akmsn ]
# # }

# # Helm Chart Installation
# # resource "helm_release" "aws_load_balancer_controller" {
# #   name       = var.lb_controller_sa_name
# #   repository = "https://aws.github.io/eks-charts"
# #   chart      = "aws-load-balancer-controller"
# #   namespace  = "kube-system"
# #   version    = var.lb_controller_chart_version
  
# #   values = [
# #     yamlencode({
# #       clusterName = aws_eks_cluster.eksdemo.name
# #       serviceAccount = {
# #         create = false
# #         name   = var.lb_controller_sa_name
# #       }
# #       vpcId = aws_vpc.EKS-TF-VPC-1.id
# #     })
# #   ]
# #   depends_on = [kubernetes_service_account.aws_lb_controller,aws_internet_gateway.EKS-TF-IG-1,aws_eks_access_entry.access_entry_akmsn]
# # }