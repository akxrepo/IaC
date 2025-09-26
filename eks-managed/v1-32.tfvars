environment = "mgd-1-32" #"auto-1-32"
eks_cluster_name = "eks-mgd-cluster-1-32" #"eks-mgd-cluster-1-32"
eks_version = "1.32"
#eks_node_instance_type = "t3.medium"
eks_ami = "AL2_x86_64" # Amazon EKS-Optimized Amazon Linux 2 AMI v1.32.9-2024.06.11
#EKS Add-on version (Ensure compatibility with EKS version)
coredns_version= "v1.11.3-eksbuild.1"
pod-identity-agent_version= "v1.3.4-eksbuild.1"
kube-proxy_version= "v1.32.0-eksbuild.2" 
metrics-server_version= "v0.8.0-eksbuild.2"
vpc-cni_version= "v1.18.1-eksbuild.1"
#ebs_csi_driver_version = "v1.48.0-eksbuild.2"
#external-dns_version= "v0.18.0-eksbuild.1"
#efs-csi-driver_version = "v2.1.11-eksbuild.1"
#kube_state_metrics_version = "v2.17.0-eksbuild.1"

