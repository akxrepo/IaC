resource "aws_autoscaling_group" "web-asg" {
  launch_template {
    id      = aws_launch_template.web-server.id
    version = "$Latest"
  }
  vpc_zone_identifier = [
    aws_subnet.test-subnet-pvt-1.id,
    aws_subnet.test-subnet-pvt-2.id
  ]
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  tag {
    key                 = "Name"
    value               = "Web-Tier-Web-ASG"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "Terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  target_group_arns = [aws_lb_target_group.web-tg.arn]
  depends_on = [
    aws_lb_listener.http
  ]
}

resource "aws_lb_target_group" "web-tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "Web-Tier-Web-TG"
  }
  depends_on = [
    aws_lb.web-alb
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
  depends_on = [
    aws_lb_target_group.web-tg
  ]
}

locals {
  public_subnet_ids = [
    aws_subnet.test-subnet-pub-1.id,
    aws_subnet.test-subnet-pub-2.id
  ]
}

resource "aws_lb" "web-alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = local.public_subnet_ids

  tags = {
    Name = "Web-Tier-Web-ALB"
  }
}
