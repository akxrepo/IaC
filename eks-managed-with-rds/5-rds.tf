resource "aws_db_instance" "eks-shopping-app" {
  identifier = "shopping-db-eks"

  engine         = "mysql"
  engine_version = "8.0.43"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = false

  db_name  = "shopping_db_eks"
  username = "root"
  # password intentionally omitted (use Secrets Manager / ignore_changes)

  port = 3306

  multi_az = false
  publicly_accessible = false

  vpc_security_group_ids = [
    aws_security_group.rds_mysql_vpc.id
  ]

  db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.name
  availability_zone    = "us-east-1b"

  backup_retention_period = 0

  auto_minor_version_upgrade = false
  copy_tags_to_snapshot      = true
  deletion_protection        = false

  parameter_group_name = "default.mysql8.0"
  option_group_name    = "default:mysql-8-0"

  performance_insights_enabled = false
  iam_database_authentication_enabled = false

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  monitoring_interval = 0

  tags = {
    Name = "eks-shopping-app-eks"
  }

  lifecycle {
    ignore_changes = [
      password,
      engine_version,
    ]
  }
}


resource "aws_security_group" "rds_mysql_vpc" {
  name        = "rds-mysql-vpc-eks"
  description = "Allow MySQL access from within VPC"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description = "MySQL from VPC CIDR"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.test-vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-mysql-vpc-eks"
  }
}

resource "aws_db_subnet_group" "rds-subnet-group" {
  name        = "rds-subnet-group-eks"
  description = "RDS subnet group for EKS"
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "rds-subnet-group-eks"
  }
}