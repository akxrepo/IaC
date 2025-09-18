# resource "aws_instance" "ec2_instance" {
#   ami           = "ami-0b09ffb6d8b58ca91" # Amazon Linux 2 AMI (HVM), SSD Volume Type
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.test-subnet-pub-1.id
#   key_name      = "akmaster" # Replace with your key pair name

#   tags = {
#     Name = "EC2Instance"
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y httpd
#               systemctl start httpd
#               systemctl enable httpd
#               EC2AZ=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone)
#               echo '<center><h1>This Amazon EC2 instance is located in Availability Zone: AZID </h1></center>' > /var/www/html/index.txt
#               sed "s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
#               EOF

#   vpc_security_group_ids = [aws_security_group.console-sg.id]

# }