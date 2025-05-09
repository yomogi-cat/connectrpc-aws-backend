# App Runnerサービス - ECRイメージから
resource "aws_apprunner_service" "app_service" {
  service_name = "app-runner-todo-api"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_role.arn
    }
    auto_deployments_enabled = true

    image_repository {
      image_configuration {
        port = 3000
        runtime_environment_variables = {
          NODE_ENV = "production"
        }
      }
      image_identifier      = "${aws_ecr_repository.api_repo.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_scaling.arn

  health_check_configuration {
    healthy_threshold   = 1
    unhealthy_threshold = 5
    interval            = 5
    path                = "/health"
    timeout             = 2
    protocol            = "HTTP"
  }

  instance_configuration {
    cpu    = 1024
    memory = 2048
  }

  # ECRリポジトリとIAMロールポリシーの両方が作成されていることを確認
  depends_on = [
    aws_ecr_repository.api_repo,
    aws_iam_role_policy_attachment.app_runner_ecr_policy_attachment
  ]
}

# App Runnerの自動スケーリング設定
resource "aws_apprunner_auto_scaling_configuration_version" "app_scaling" {
  auto_scaling_configuration_name = "app-runner-scaling-config"
  max_concurrency                 = 50
  max_size                        = 5
  min_size                        = 1
}
