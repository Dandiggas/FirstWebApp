terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}


data "aws_subnet" "default_a" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "eu-west-1a"
}

data "aws_subnet" "default_b" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "eu-west-1b"
}

data "aws_subnet" "default_c" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "eu-west-1c"
}

resource "aws_ecs_cluster" "dan" {
  name = "diggas"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "dan_capacity_provider" {
  cluster_name = aws_ecs_cluster.dan.name

  capacity_providers = ["${aws_ecs_capacity_provider.test.name}"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "${aws_ecs_capacity_provider.test.name}"
  }
}

resource "aws_ecs_capacity_provider" "test" {
  name = "test"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.bar.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 1
      maximum_scaling_step_size = 1
    }
  }

}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}
resource "aws_launch_template" "test" {
  name_prefix = "test"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }

  image_id      = "ami-00b1c9efd33fda707"
  instance_type = "t3.large"


user_data = base64encode(
    <<-EOF
      #!/bin/bash
      echo "ECS_CLUSTER=diggas" >> /etc/ecs/ecs.config
    EOF
  )
}


resource "aws_autoscaling_group" "bar" {
  availability_zones = ["eu-west-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.test.id
    version = "$Latest"
  }
  protect_from_scale_in = true
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_ecs_task_definition" "tformtest" {
  family = "tformtest"
  container_definitions = jsonencode([
    {
      name               = "tform"
      image              = "public.ecr.aws/v8j0g7n1/firstwebapp:latest"
      cpu                = 2048
      memory             = 4096
      essential          = true
      execution_role_arn = "ecsTaskExecutionRole"
      network_mode       = "default"

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    },
  ])

}
resource "aws_ecs_service" "test_service" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.dan.id
  task_definition = aws_ecs_task_definition.tformtest.id

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  desired_count = 1
}


data "aws_vpc" "default" {
  default = true
}

data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}


