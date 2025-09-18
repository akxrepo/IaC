resource "aws_launch_template" "web-server" {
  name_prefix   = "web-server-"
  image_id      = "ami-0b09ffb6d8b58ca91" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.micro"

  network_interfaces {
    #associate_public_ip_address = true
    security_groups             = [aws_security_group.alb-to-ec2-sg.id]
    subnet_id                   = element([aws_subnet.test-subnet-pub-1.id, aws_subnet.test-subnet-pub-2.id], 0)
  }

  user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                EC2AZ=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone)
                echo '<center><h1>This Amazon EC2 instance is located in Availability Zone: AZID </h1></center>' > /var/www/html/index.txt
                sed "s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
                EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServerInstance"
    }
  }

}