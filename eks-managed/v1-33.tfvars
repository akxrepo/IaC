eks_cluster_name = "eks-mgd-cluster-1-33" #"eks-mgd-cluster-1-32"
eks_version = "1.33"
#eks_node_instance_type = "t3.medium"
eks_ami = "AL2023_x86_64_STANDARD" # Amazon EKS-Optimized Amazon Linux 2 AMI v1.32.9-2024.06.11
#EKS Add-on version (Ensure compatibility with EKS version)
coredns_version= "v1.12.1-eksbuild.2"
pod-identity-agent_version= "v1.3.8-eksbuild.2"
kube-proxy_version= "v1.33.0-eksbuild.2" 
metrics-server_version= "v0.8.0-eksbuild.2"
vpc-cni_version= "v1.19.5-eksbuild.1"
ebs_csi_driver_version = "v1.48.0-eksbuild.2"
external-dns_version= "v0.18.0-eksbuild.1"
efs-csi-driver_version = "v2.1.11-eksbuild.1"
kube_state_metrics_version = "v2.17.0-eksbuild.1"

#####
# aws-ebs-csi-driver = v1.48.0-eksbuild.2
# aws-efs-csi-driver = v2.1.11-eksbuild.1
# aws-mountpoint-s3-csi-driver = v2.0.0-eksbuild.1
# cert-manager = v1.18.2-eksbuild.2
# external-dns = v0.19.0-eksbuild.2
# kube-state-metrics = v2.17.0-eksbuild.1
# prometheus-node-exporter = v1.9.1-eksbuild.4

