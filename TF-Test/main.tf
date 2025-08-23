data "aws_vpc" "optus-vpc" {
  id = "vpc-04b4d0ec79ead4ac2"
}

# data "aws_security_group" "console-sg" {
#   id = "sg-001464ea1f2b0dab9"
# }

# resource "aws_vpc_security_group_vpc_association" "assoc_secondary" {
#   security_group_id = data.aws_security_group.console-sg.id
#   vpc_id            = data.aws_vpc.optus-vpc.id
# }

data "aws_subnets" "alb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.optus-vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["ALB"]
  }
}

# resource "aws_instance" "name" {
#   ami = "ami-020cba7c55df1f615"
#   instance_type = "t2.micro"
#   count = 4
#   subnet_id = element(data.aws_subnets.db.ids[*], count.index % length(data.aws_subnets.db.ids))
# }


