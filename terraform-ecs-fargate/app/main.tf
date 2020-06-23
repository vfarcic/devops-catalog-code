resource "aws_ecs_task_definition" "dts" {
  family                   = "devops-toolkit-series"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("devops-toolkit-series.json")
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "dts" {
  name            = "devops-toolkit-series"
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.dts.arn
  cluster         = var.cluster_id
  desired_count   = var.desired_count
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
  }
  load_balancer {
    target_group_arn = var.lb_arn
    container_name   = "devops-toolkit-series"
    container_port   = var.port
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}
