
# # resource "aws_iam_policy" "ebs_csi_policy" {
# #   name   = "AmazonEBSCSIDriverPolicy"
# #   policy = file("${path.module}/ebs-csi-policy.json")
# # }

# resource "aws_iam_policy" "ebs_csi_policy" {
#   name        = "example-policy"
#   description = "IAM policy to allow read-only access to S3 bucket"
#   path        = "/"

#   policy = jsonencode({
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:AttachVolume",
#         "ec2:CreateSnapshot",
#         "ec2:CreateTags",
#         "ec2:CreateVolume",
#         "ec2:DeleteSnapshot",
#         "ec2:DeleteTags",
#         "ec2:DeleteVolume",
#         "ec2:DescribeInstances",
#         "ec2:DescribeSnapshots",
#         "ec2:DescribeTags",
#         "ec2:DescribeVolumes",
#         "ec2:DetachVolume"
#       ],
#       "Resource": "*"
#     }
#   ]
# })
# }

# resource "aws_iam_role" "ebs_csi_irsa" {
#   name = "eks-ebs-csi-driver-irsa"

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
#             "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#           }
#         }
#       }
#     ]
#   })
#   depends_on = [ aws_eks_cluster.eksdemo ]
# }

# # Step 4: Attach IAM Policy to Role
# # data "aws_iam_policy" "aws_ebs" {
# #   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# # }

# resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
#   role       = aws_iam_role.ebs_csi_irsa.name
#   policy_arn = aws_iam_policy.ebs_csi_policy.arn
# }

# # resource "kubernetes_service_account" "ebs_csi_sa" {
# #   metadata {
# #     name      = "ebs-csi-controller-sa"
# #     namespace = "kube-system"
# #     labels = {  "app.kubernetes.io/component"="csi-driver", 
# #                 "app.kubernetes.io/managed-by"="EKS", 
# #                 "app.kubernetes.io/name"="aws-ebs-csi-driver",
# #                 "app.kubernetes.io/version"="1.45.0"
# #             }
# #     annotations = {
# #       "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_irsa.arn
# #     }
# #   }
# #   depends_on = [ aws_eks_node_group.tf-eks-nodegroup-1,
# #                  aws_internet_gateway.EKS-TF-IG-1,
# #                  aws_eks_access_entry.access_entry_akmsn ]
# # }

# # resource "helm_release" "ebs_csi_driver" {
# #   name       = "aws-ebs-csi-driver"
# #   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
# #   chart      = "aws-ebs-csi-driver"
# #   namespace  = "kube-system"
# #   version    = "2.25.0"

# #   values = [yamlencode({
# #     controller = {
# #       serviceAccount = {
# #         create = false
# #         name   = kubernetes_service_account.ebs_csi_sa.metadata[0].name
# #       }
# #     }
# #     enableVolumeScheduling = true
# #   })]


# #   depends_on = [
# #     kubernetes_service_account.ebs_csi_sa,
# #     aws_iam_role_policy_attachment.ebs_csi_attach,
# #     aws_eks_access_entry.access_entry_akmsn
# #   ]
# # }

