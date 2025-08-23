resource "aws_instance" "k8s" {
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = data.aws_key_pair.akloud.key_name
  security_groups   = [data.aws_security_group.console-security-group.name]
  availability_zone = var.spot_az1
  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price                      = "0.02"      # Optional: max you're willing to pay
      spot_instance_type             = "one-time"  # or "persistent"
      instance_interruption_behavior = "terminate" # or "stop", "hibernate"
    }
  }

  tags = {
    Name      = "spot-k8s"
    AK        = "Terraform"
    Terraform = "true"
  }
}

data "aws_security_group" "console-security-group" {
  name = "Console-SG-1"
}

data "aws_key_pair" "akloud" {
  key_name = var.ssh_key_name
}

resource "aws_s3_bucket" "name" {
  bucket = "test"
}
