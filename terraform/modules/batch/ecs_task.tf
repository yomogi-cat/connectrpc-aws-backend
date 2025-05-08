# 統計バッチ用タスク定義
resource "aws_ecs_task_definition" "stats_task" {
  family                   = "${local.project_name}-stats-batch"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.env.container_base_config.cpu
  memory                   = local.env.container_base_config.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    merge(local.env.container_base_config, {
      name    = "stats-batch"
      image   = "${aws_ecr_repository.batch_repo.repository_url}:latest"
      command = split(" ", local.env.batch_stats_params)
    })
  ])
}

# エクスポートバッチ用タスク定義
resource "aws_ecs_task_definition" "export_task" {
  family                   = "${local.project_name}-export-batch"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.env.container_base_config.cpu
  memory                   = local.env.container_base_config.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    merge(local.env.container_base_config, {
      name    = "export-batch"
      image   = "${aws_ecr_repository.batch_repo.repository_url}:latest"
      command = split(" ", local.env.batch_export_params)
    })
  ])
}

# クリーンアップバッチ用タスク定義
resource "aws_ecs_task_definition" "cleanup_task" {
  family                   = "${local.project_name}-cleanup-batch"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.env.container_base_config.cpu
  memory                   = local.env.container_base_config.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    merge(local.env.container_base_config, {
      name    = "cleanup-batch"
      image   = "${aws_ecr_repository.batch_repo.repository_url}:latest"
      command = split(" ", local.env.batch_cleanup_params)
    })
  ])
}