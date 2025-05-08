# クリーンアップバッチ用のスケジューラ
resource "aws_scheduler_schedule" "cleanup_schedule" {
  name                = "${local.project_name}-cleanup-schedule"
  description         = "Cleanup batch"
  schedule_expression = "cron(0/5 * * * ? *)"
  
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.batch_cluster.arn
    role_arn = aws_iam_role.scheduler_role.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.cleanup_task.arn
      launch_type         = "FARGATE"
      task_count          = 1

      network_configuration {
        subnets          = aws_subnet.batch_private_subnet[*].id
        security_groups  = [aws_security_group.batch_tasks.id]
        assign_public_ip = false
      }
    }
  }
}

# エクスポートバッチ用のスケジューラ
resource "aws_scheduler_schedule" "export_schedule" {
  name                = "${local.project_name}-export-schedule"
  description         = "Export batch"
  schedule_expression = "cron(0 3 * * ? *)"
  
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.batch_cluster.arn
    role_arn = aws_iam_role.scheduler_role.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.export_task.arn
      launch_type         = "FARGATE"
      task_count          = 1

      network_configuration {
        subnets          = aws_subnet.batch_private_subnet[*].id
        security_groups  = [aws_security_group.batch_tasks.id]
        assign_public_ip = false
      }
    }
  }
}

# 統計バッチ用のスケジューラ
resource "aws_scheduler_schedule" "stats_schedule" {
  name                = "${local.project_name}-stats-schedule"
  description         = "Stats batch"
  schedule_expression = "cron(0 6 * * ? *)"
  
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.batch_cluster.arn
    role_arn = aws_iam_role.scheduler_role.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.stats_task.arn
      launch_type         = "FARGATE"
      task_count          = 1

      network_configuration {
        subnets          = aws_subnet.batch_private_subnet[*].id
        security_groups  = [aws_security_group.batch_tasks.id]
        assign_public_ip = false
      }
    }
  }
}

