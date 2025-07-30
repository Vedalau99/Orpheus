resource "aws_ecr_repository" "orpheus_repo" {
  name = "orpheus-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#     VPC + subnets + internetgateway

resource "aws_vpc" "orpheus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "orpheus-vpc" }
}

resource "aws_internet_gateway" "orpheus_igw" {
  vpc_id = aws_vpc.orpheus_vpc.id
  tags = { Name = "orpheus-igw" }
}

resource "aws_subnet" "orpheus_subnet" {
  vpc_id                  = aws_vpc.orpheus_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "orpheus-subnet" }
}

resource "aws_route_table" "orpheus_rt" {
  vpc_id = aws_vpc.orpheus_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.orpheus_igw.id
  }
  tags = { Name = "orpheus-rt" }
}

resource "aws_route_table_association" "orpheus_rta" {
  subnet_id      = aws_subnet.orpheus_subnet.id
  route_table_id = aws_route_table.orpheus_rt.id
}




# Security Group

resource "aws_security_group" "orpheus_sg" {
  name        = "orpheus-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.orpheus_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "orpheus-sg" }
}




#IAM role

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "orpheus-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "cloudwatch-metrics"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



# ECS clusters & task definition

resource "aws_ecs_cluster" "orpheus_cluster" {
  name = "orpheus-cluster"
}

resource "aws_ecs_task_definition" "orpheus_task" {
  family                   = "orpheus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "orpheus-container"
      image     = aws_ecr_repository.orpheus_repo.repository_url
      essential = true
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ],
      environment = [
      	{
          name  = "REDEPLOY_TRIGGER"
          value = "1"
      	}
      ]	
    }
  ])
}


# ECS fargate service


resource "aws_ecs_service" "orpheus_service" {
  name            = "orpheus-service"
  cluster         = aws_ecs_cluster.orpheus_cluster.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.orpheus_task.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "orpheus-app"
    container_port   = 80
  }

  network_configuration {
    subnets         = [aws_subnet.orpheus_subnet.id]
    security_groups = [aws_security_group.orpheus_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_role_policy,
    aws_lb_listener.app_listener
  ]
}


output "public_ip" {
  value = aws_ecs_service.orpheus_service.network_configuration[0].assign_public_ip
  description = "Public IP assigned to the Fargate task"
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
  description = "Public URL for Orpheus app"
}

