# configure main.tf for ecs 

resource "aws_lb" "ecs_main" {
  name               = "${var.env_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]
}

resource "aws_alb_target_group" "ecs_main" {
  name        = "${var.env_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_main.arn
  }
}

# configure ECS 

resource "aws_ecs_cluster" "ecs_main" {
  name = "${var.env_name}-ecs-cluster"
}


resource "aws_ecs_task_defination" "ecs_main" {
  family                   = "${var.env_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  containers_definations = jsonencode([{
    name         = "${var.env_name}-app"
    image        = var.container_image
    portMappings = [{ containerPort = var.container_port }]
    environment = [
      {
        name  = "DB_ENDPOINT"
        value = var.db_endpoint
      }
    ]
  }])
}

resource "aws_ecs_service" "ecs_main" {
  name            = "${var.env_name}-service"
  cluster         = aws_ecs_cluster.ecs_main.id
  task_definition = aws_ecs_task_defination.ecs_main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_main.arn
    container_name   = "${var.env_name}-app"
    container_port   = var.container_port

  }

  depends_on = [aws_lb_listener.http]
}
