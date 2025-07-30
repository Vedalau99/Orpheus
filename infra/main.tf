provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Create VPC
resource "aws_vpc" "orpheus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "orpheus-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "orpheus_igw" {
  vpc_id = aws_vpc.orpheus_vpc.id
  tags = {
    Name = "orpheus-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "orpheus_public_subnet" {
  vpc_id                  = aws_vpc.orpheus_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "orpheus-public-subnet"
  }
}

# Create Route Table
resource "aws_route_table" "orpheus_public_rt" {
  vpc_id = aws_vpc.orpheus_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.orpheus_igw.id
  }
  tags = {
    Name = "orpheus-public-rt"
  }
}

# Associate Route Table
resource "aws_route_table_association" "orpheus_public_rta" {
  subnet_id      = aws_subnet.orpheus_public_subnet.id
  route_table_id = aws_route_table.orpheus_public_rt.id
}

# ECS Cluster
resource "aws_ecs_cluster" "orpheus_cluster" {
  name = "orpheus-cluster"
}

# IAM Role for Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "orpheus_task" {
  family                   = "orpheus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "orpheus"
      image     = "public.ecr.aws/docker/library/python:3.11"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      command = ["python3", "-m", "http.server", "5000"]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "orpheus_service" {
  name            = "orpheus-service"
  cluster         = aws_ecs_cluster.orpheus_cluster.id
  task_definition = aws_ecs_task_definition.orpheus_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.orpheus_public_subnet.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.alb_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.orpheus_tg.arn
    container_name   = "orpheus"
    container_port   = 5000
  }
  depends_on = [aws_lb_listener.orpheus_listener]
}

output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer"
  value       = aws_lb.orpheus_alb.dns_name
}

output "vpc_id" {
  value = aws_vpc.orpheus_vpc.id
}

output "public_subnets" {
  value = [aws_subnet.orpheus_public_subnet.id]
}
