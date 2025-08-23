data "aws_key_pair" "akloud" {
  key_name = "AKloud-Console"
}


# resource "aws_instance" "name" {
#   ami                         = "ami-020cba7c55df1f615"
#   instance_type               = "t2.micro"
#   key_name                    = data.aws_key_pair.akloud.key_name
#   associate_public_ip_address = true
#   count                       = 1
#   subnet_id                   = element(data.aws_subnets.alb_subnets.ids[*], count.index % length(data.aws_subnets.alb_subnets.ids))
#   user_data                   = <<-EOF
#               #!/bin/bash
#               apt-get update -y
#               apt-get install -y nginx
#               systemctl enable nginx
#               systemctl start nginx
#               EOF
# }