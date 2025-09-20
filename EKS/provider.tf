provider "aws" {
  region = "us-east-1"
  profile = "sv-lab-admin"
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "svkv-terraform-state-bucket"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    profile      = "sv-lab-admin"
    use_lockfile = true
    encrypt      = true
  }
}

# provider "kubernetes" {
#   config_path = "C:\\Users\\Ashok\\.kube\\config"
# }

# provider "helm" {
#   kubernetes = {
#     config_path = "C:\\Users\\Ashok\\.kube\\config"
#   }
# }

