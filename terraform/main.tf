terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


  backend "s3" {
    bucket         = "firstwebsite-tf-state-backend"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"

  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "DanVpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "DanVpc"
  }
  enable_dns_hostnames = true
}

resource "aws_subnet" "DanSubnet" {
  vpc_id            = aws_vpc.DanVpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "DanSubnet"
  }
  # Auto-assign public IPv4 addresses to instances launched in this subnet
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "DanGateway" {
  vpc_id = aws_vpc.DanVpc.id

  tags = {
    Name = "DanGateway"
  }
}

resource "aws_route_table" "DanRoute" {
  vpc_id = aws_vpc.DanVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DanGateway.id
  }

  tags = {
    Name = "DanRoute"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.DanSubnet.id
  route_table_id = aws_route_table.DanRoute.id
}

resource "aws_security_group" "Dansec" {
  vpc_id = aws_vpc.DanVpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  # Ingress rule for HTTP (port 80)
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for SSH (port 22)
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for SSH (port 22)
  ingress {
    description = "Allow SSH traffic"
    from_port   = 8000
    to_port     = 8000
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
    Name = "DanSec"
  }

}

resource "aws_ecs_cluster" "dan" {
  name = "diggas"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role" "execution_role" {
  name = "execution-ecs-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
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

resource "aws_iam_role_policy_attachment" "ecs_agent_permissions" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "instance_profile" {
  name = "comeon-instanceprofile"
  role = aws_iam_role.execution_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_permissions" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}



resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-0bf5ac026c9b5eb88"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.Dansec.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t3.large"


}




resource "aws_autoscaling_group" "bar" {
  name                 = "asg"
  vpc_zone_identifier  = [aws_subnet.DanSubnet.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name



  desired_capacity = 1
  max_size         = 1
  min_size         = 1

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


resource "aws_ecs_cluster_capacity_providers" "dan_capacity_provider" {
  cluster_name = aws_ecs_cluster.dan.name

  capacity_providers = ["${aws_ecs_capacity_provider.test.name}"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.test.name
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

