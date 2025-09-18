terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket       = "svkv-terraform-state-bucket"
    key          = "3-tier/terraform.tfstate"
    region       = "us-east-1"
    profile      = "sv-lab-admin"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "sv-lab-admin"
}

