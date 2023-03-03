# Creating an ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Creating an ECS task definition
resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = 512
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name : "nginx",
      image : "nginx:1.23.1",
      cpu : 512,
      memory : 2048,
      essential : true,
      portMappings : [
        {
          containerPort : 80,
          hostPort : 80,
        },
      ],
    },
  ])
}

# Creating an ECS service
resource "aws_ecs_service" "service" {
  name             = "service"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = [aws_subnet.public_subnet.id]
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}