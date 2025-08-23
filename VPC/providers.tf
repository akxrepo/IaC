provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      AK        = "Terraform"
      Terraform = "true"
    }
  }
}