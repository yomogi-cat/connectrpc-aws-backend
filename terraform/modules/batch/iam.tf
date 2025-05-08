# EventBridge Scheduler用のIAMロール
resource "aws_iam_role" "scheduler_role" {
  name = "${local.project_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

# EventBridge Scheduler用のポリシー
resource "aws_iam_policy" "scheduler_policy" {
  name        = "${local.project_name}-batch-scheduler-policy"
  description = "Policy for EventBridge Scheduler to run ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ecs:RunTask"
        Resource = [
          aws_ecs_task_definition.cleanup_task.arn,
          aws_ecs_task_definition.export_task.arn,
          aws_ecs_task_definition.stats_task.arn
        ]
        Condition = {
          ArnLike = {
            "ecs:cluster" = aws_ecs_cluster.batch_cluster.arn
          }
        }
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.task_execution_role.arn,
          aws_iam_role.task_role.arn
        ]
      }
    ]
  })
}

# EventBridge Scheduler用のポリシーアタッチメント
resource "aws_iam_role_policy_attachment" "scheduler_policy_attachment" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

# タスク実行ロール
resource "aws_iam_role" "task_execution_role" {
  name = "${local.project_name}-batch-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# タスク実行ロールポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_ecr_readonly_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# タスクロール
resource "aws_iam_role" "task_role" {
  name = "${local.project_name}-batch-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# タスクロールポリシー
resource "aws_iam_policy" "batch_task_policy" {
  name        = "${local.project_name}-batch-task-policy"
  description = "Policy for batch task roles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.project_name}-exports/*",
          "arn:aws:s3:::${local.project_name}-exports"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.batch_logs.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# タスクロールポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "task_role_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.batch_task_policy.arn
}