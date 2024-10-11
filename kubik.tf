provider "aws" {
  region     = "eu-central-1"  # Задайте регіон
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  name        = "kubuk-testr"  # Назва інфраструктури
  vpc_cidr    = "10.127.0.0/16" # CIDR для VPC
  azs         = ["eu-central-1a", "eu-central-1b"]  # Доступні зони

  public_subnets  = ["10.127.1.0/24", "10.127.2.0/24"]
  private_subnets = ["10.127.3.0/24", "10.127.4.0/24"]
  intra_subnets   = ["10.127.5.0/24", "10.127.6.0/24"]
}

# Додавання модуля VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name                 = local.name
  cidr                 = local.vpc_cidr
  azs                  = local.azs
  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  intra_subnets        = local.intra_subnets

  enable_nat_gateway = true  # Включення NAT Gateway
}

# Додавання EC2 інстансу
resource "aws_instance" "EC2-Instance" {
  availability_zone      = "eu-central-1a"  # Зона доступності
  ami                    = "ami-0e04bcbe83a83792e"  # AMI ID
  instance_type          = "t2.large"  # Тип інстансу
  key_name               = var.key_name  # SSH ключ
  vpc_security_group_ids = [aws_security_group.sayt.id]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 30
    volume_type           = "standard"
    delete_on_termination = true
    tags = {
      Name = "root-disk"
    }
  }

  user_data = file("${path.module}/sayt_jenkins_doer.sh")

  tags = {
    Name = "EC2-Instance"
  }
}

# Додавання EKS кластеру
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = var.eks_cluster_name
  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_ARM_64"
    instance_types = ["t4g.medium"]  # Інстанс ARM
    key_name       = var.key_name
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t4g.medium"]
      capacity_type  = "SPOT"

      tags = {
        Name = "EKS-Worker-Node"
      }
    }
  }

  tags = {
    Name = "EKS-cluster"
  }
}

# Додавання Security Group для EC2
resource "aws_security_group" "sayt" {
  name        = "sayt"
  description = "Allow 22, 80, 443, 8080, and other ports inbound traffic"

  dynamic "ingress" {
    for_each = [22, 80, 443, 8080, 8000, 81, 55555, 1433, 5034, 5173, 5181, 5432, 8220, 5601, 9600, 9300, 9090, 9100, 3000, 8081]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group"
  }
}

# Додавання S3 бакету для стану Terraform
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-proet-terraform-state-bucket"  # Унікальне ім'я

  tags = {
    Name        = "My Terraform Bucket"
    Environment = "Dev"
  }
}

# Додавання DynamoDB таблиці для блокування стану Terraform
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock-table-unique"  # Унікальне ім'я
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Додавання Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  desired_capacity     = 1
  max_size             = 5
  min_size             = 1
  vpc_zone_identifier = module.vpc.private_subnets
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

# Додавання Launch Template
resource "aws_launch_template" "example" {
  name          = "example-launch-template"
  image_id     = "ami-0e04bcbe83a83792e"  # Використовується AMI
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

# Додавання CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high_cpu_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "70"
  alarm_description   = "Моніторинг CPU"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# Додавання політик масштабування
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment      = 1
  adjustment_type       = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment      = -1
  adjustment_type       = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

# Додавання прогнозованого масштабування
resource "aws_autoscaling_policy" "predictive_scaling" {
  name                   = "predictive_scaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1  # Задайте необхідний рівень масштабування
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}

# Додавання DNS зони та запису для Qubix-social.com
resource "aws_route53_zone" "qubix_social_zone" {
  name = "qubix-social.com"
}

resource "aws_route53_record" "qubix_social" {
  zone_id = aws_route53_zone.qubix_social_zone.zone_id
  name    = "Qubix-social.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.EC2-Instance.public_ip]
}

# Додавання Elastic Load Balancer
resource "aws_elb" "qubix_elb" {
  name               = "qubix-elb"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 5173
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5173/"
    interval            = 30
  }

  tags = {
    Name = "qubix-elb"
  }
}

# Додавання Security Group для ELB
resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Security group for ELB"
  vpc_id      = module.vpc.vpc_id  # Переконайтеся, що це правильний VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb_sg"
  }
}
