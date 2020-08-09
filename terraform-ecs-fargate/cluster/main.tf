provider "aws" {
  region = var.region
}

#######
# ECS #
#######

resource "aws_ecs_cluster" "main" {
  name = "catalog-ecs"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

resource "aws_iam_role" "ecs_task" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task.name
}

###################
# Everything Else #
###################

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    "Name" = "catalog-ecs"
  }
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    "Name" = "catalog-ecs"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name" = "catalog-ecs"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "main" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.main.*.id, count.index)
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "main" {
  name        = "catalog-ecs"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_security_group" "lb" {
  name        = "catalog-ecs-lb"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_lb" "main" {
  name               = "catalog-ecs"
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_lb_target_group" "main" {
  name        = "catalog-ecs"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  tags = {
    Name = "catalog-ecs"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}
