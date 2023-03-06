# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Create a new VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

# Create a new subnet in the VPC
resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "MySubnet"
  }
}

# Create a new security group
resource "aws_security_group" "example" {
  name_prefix = "MySecurityGroup"
  vpc_id      = aws_vpc.example.id

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
}

# Create a new target group
resource "aws_lb_target_group" "example" {
  name_prefix      = "MyTargetGroup"
  port             = 80
  protocol         = "HTTP"
  target_type      = "instance"
  vpc_id           = aws_vpc.example.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 2
  }
}

# Create a new load balancer
resource "aws_lb" "example" {
  name_prefix      = "MyLoadBalancer"
  internal         = false
  load_balancer_type = "application"
  security_groups  = [aws_security_group.example.id]
  subnets          = [aws_subnet.example.id]

  enable_deletion_protection = false

  tags = {
    Name = "MyLoadBalancer"
  }

  depends_on = [
    aws_lb_target_group.example,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Add a listener to the load balancer
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.example.arn
    type             = "forward"
  }
}
