resource "aws_autoscaling_group" "bar" {
  name                 = "asg"
  vpc_zone_identifier  = [aws_subnet.DanSubnet.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name



  desired_capacity = 1
  max_size         = 1
  min_size         = 1

}