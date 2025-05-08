# CloudWatch Logs グループ
resource "aws_cloudwatch_log_group" "batch_logs" {
  name              = "/ecs/${local.project_name}"
  retention_in_days = local.env.log_retention_in_days
}
