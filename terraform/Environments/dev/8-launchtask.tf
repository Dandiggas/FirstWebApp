resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-0bf5ac026c9b5eb88"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.Dansec.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t3.large"


}