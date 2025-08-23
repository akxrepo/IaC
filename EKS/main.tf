provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path = "C:\\Users\\Ashok\\.kube\\config"
}

provider "helm" {
  kubernetes = {
    config_path = "C:\\Users\\Ashok\\.kube\\config"
  }
}

