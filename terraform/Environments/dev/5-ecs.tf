resource "aws_ecs_cluster" "dan" {
  name = "diggas"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}