# ECSクラスター
resource "aws_ecs_cluster" "batch_cluster" {
  name = "${local.project_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}