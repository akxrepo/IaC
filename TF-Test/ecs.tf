# resource "aws_security_group" "alb_sg" {
#   vpc_id = data.aws_vpc.optus-vpc.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# #ALB
# resource "aws_lb" "nginx_alb" {
#   name               = "nginx-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [data.aws_security_group.console-sg.id]
#   subnets            = data.aws_subnets.alb.ids
# }

# resource "aws_lb_target_group" "nginx_tg" {
#   name     = "nginx-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.optus-vpc.id
#   target_type = "ip"
#   health_check {
#     path = "/"
#     protocol = "HTTP"
#   }
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.nginx_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nginx_tg.arn
#   }
# }


# #IAM Role
# resource "aws_iam_role" "ecs_execution" {
#   name = "ecsExecutionRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "ecs-tasks.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
#   role       = aws_iam_role.ecs_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# #ECS Cluster
# resource "aws_ecs_cluster" "nginx" {
#   name = "nginx-cluster"
# }

# resource "aws_ecs_task_definition" "nginx" {
#   family                   = "nginx-task"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"
#   network_mode             = "awsvpc"
#   execution_role_arn       = aws_iam_role.ecs_execution.arn

#   container_definitions = jsonencode([
#     {
#       name  = "nginx"
#       image = "nginx:stable-alpine3.21"
#       portMappings = [
#         {
#           containerPort = 80
#           protocol      = "tcp"
#         }
#       ]
#     }
#   ])
# }

# resource "aws_ecs_service" "nginx" {
#   name            = "nginx-service"
#   cluster         = aws_ecs_cluster.nginx.id
#   task_definition = aws_ecs_task_definition.nginx.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets         = data.aws_subnets.alb.ids
#     assign_public_ip = true
#     security_groups = [aws_security_group.alb_sg.id]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.nginx_tg.arn
#     container_name   = "nginx"
#     container_port   = 80
#   }

#   depends_on = [aws_lb_listener.http]
# }