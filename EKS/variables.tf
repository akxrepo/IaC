variable "aws_keys" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7HM6drUBM0Jd7Kt2FpiW627MrR4OEl+LCNdf4iesaNWw5GTxqj9UEk9nrbNj9J24ug7HbxxYmQqH+8l/JgGgpdVCAnP1/gdpc9MvVqPDJ+bkyNeelgwIb257pjskkoAEej0qEP5KFAdHcok0i/419KynkTMZeecAwoyfZLShRl9ZZf4nzu+dJ10J9wmMZsyQ6IrSSe8rIdgmQmJ19CgNONDArzT/NQsXjFvhGKSETa8XOmYo4/zDgn/rmtXCDpDjKN5MIxZws0iI0ipwcut5jAK63+ToDtoxZNK5RO/0/q06W1aW04dQmzFsNxqtQ1jiZHT99khxbX6Pl7m6fw/5r9rMfpEBsXy3fjf+0wm+x3g0m+Kma+RYRVT0mmekMtAbiSZqROjr8o46PHMDylTsYz87zMVQmF88/ChayMaopZ/m/jvikqEccEOz+GO2GJr0vYBn7llIqQ19gYVbJZ1wvcu+jxXYmdX8IM0XFnCXfqcAPzO4wFAuBlLpVwacnqT0= Ashok@DESKTOP-0EGRQHK"
}

variable "eks_cluster_name" {
  default = "tf-eks-demo1"
}

variable "coredns_version" {
  default = "v1.12.1-eksbuild.2"
}

variable "ebs_csi_driver_version" {
  default = "v1.45.0-eksbuild.2"
}

variable "pod-identity-agent_version" {
  default = "v1.3.7-eksbuild.2"
}

variable "external-dns_version" {
  default = "v0.18.0-eksbuild.1"
}

variable "kube-proxy_version" {
  default = "v1.33.0-eksbuild.2"
}

variable "metrics-server_version" {
  default = "v0.7.2-eksbuild.4"
}

variable "vpc-cni_version" {
  default = "v1.19.5-eksbuild.1"
}

variable "efs-csi-driver_version" {
  default = "v2.1.9-eksbuild.1"
}

variable "lb_controller_sa_name" {
  default = "aws-load-balancer-controller"
}

variable "lb_controller_chart_version" {
  default     = "1.13.0"
  description = "Helm chart version for AWS Load Balancer Controller"
}

variable "ingress_ports_node_port" {
  type = map(object({
    from_port = number
    to_port   = number
  }))
  default = {
    nodeport_range_1 = {
      from_port = 30000
      to_port   = 32767
    },
  }
}

variable "ingress_ports" {
  default = {
    "22"    = "SSH"
    "80"    = "HTTP"
    "443"   = "HTTPS"
    "8080"  = "Jenkins"
    "8081"  = "Nexus"
    "9000"  = "SonarQube"
    "8200"  = "Vault"
    "3306"  = "Mysql"
    "10250" = "EKS API1"
    "4443"  = "EKS API1"
  }
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "akloud"
}

variable "spot_price-az1" {
  default     = 0.0094
  description = "us-east-1c"
}

variable "spot_price-az2" {
  default     = 0.0097
  description = "us-east-1a"
}

variable "spot_az1" {
  default = "us-east-1c"
}

variable "spot_az2" {
  default = "us-east-1a"
}

variable "eks_ami" {
  #default = "ami-00134b5b7db0c9684" #1.30
  #default = "ami-003ce8cb968027b75" #1.31 standard
  default = "ami-00b8a8df2025256aa" #1.33
}

variable "eks_version" {
  default = "1.33"
}

variable "eks_node_instance_type" {
  #default = "t2.medium"
  default = "t3.medium"
}

variable "vm_name" {
  default = {
    "Jenkins"   = "Jenkins"
    "Nexus"     = "Nexus"
    "SonarQube" = "SonarQube"
  }
}


variable "subnet_ids" {
  type = list(string)
  default = [
    "aws_subnet.EKS-TF-SUB-PUB-1",
    "aws_subnet.EKS-TF-SUB-PUB-2",
    "aws_subnet.EKS-TF-SUB-PVT-PUB-1",
    "aws_subnet.EKS-TF-SUB-PVT-PUB-2"
  ]
}

variable "nodegroup_policy" {
  type = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}