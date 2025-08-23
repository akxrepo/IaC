# data "aws_availability_zones" "az" {
#   filter {
#     name   = "zone-name"
#     values = ["1a", "1b"]  # acts like a "contains" match for these AZs
#   }

#   state = "available"
# }


data "aws_route_table" "name-rt" {
  vpc_id = aws_vpc.optus-vpc.id
}