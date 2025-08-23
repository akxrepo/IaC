# Node Group Launch Template
resource "aws_launch_template" "eks_node_lt" {
  name_prefix   = "eks-spot-node-"
  #instance_type = var.eks_node_instance_type
  key_name = var.ssh_key_name
  vpc_security_group_ids = [
    aws_security_group.EKS-TD-TF-SSH-HTTP.id
  ]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20 # Specify the desired disk size in GiB
      volume_type = "gp3"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-spot-node"
      AK = "Terraform"
      Terraform = "true"
    }
  }
}

# Node Group
resource "aws_eks_node_group" "tf-eks-nodegroup-1" {
  cluster_name    = aws_eks_cluster.eksdemo.name
  #version = var.eks_version
  node_group_name = "tf-eks-nodegroup-1"
  node_role_arn   = aws_iam_role.tf-eks-cluster-node-group-role.arn
  #ami_type = var.eks_ami
  capacity_type = "SPOT"
  instance_types = [var.eks_node_instance_type]
  #disk_size = 25
  subnet_ids      = [aws_subnet.EKS-TF-SUB-PUB-1.id,aws_subnet.EKS-TF-SUB-PUB-2.id,
                    aws_subnet.EKS-TF-SUB-PVT-PUB-1.id,aws_subnet.EKS-TF-SUB-PVT-PUB-2.id]
    
   launch_template {
    id      = aws_launch_template.eks_node_lt.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  
#   remote_access {
#     ec2_ssh_key = var.ssh_key_name
#     source_security_group_ids = [aws_security_group.EKS-TD-TF-SSH-HTTP.id]
#   }
}