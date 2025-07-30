#security group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

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

#load balancer
resource "aws_lb" "orpheus_alb" {
  name               = "orpheus-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets
}
resource "aws_lb" "orpheus_alb" {
  name               = "orpheus-app-alb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.orpheus_public_subnet.id,
    aws_subnet.orpheus_public_subnet_2.id
  ]

  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "orpheus-alb"
  }
}


resource "aws_lb_target_group" "orpheus_tg" {
  name        = "orpheus-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener" "orpheus_listener" {
  load_balancer_arn = aws_lb.orpheus_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orpheus_tg.arn
  }
}
