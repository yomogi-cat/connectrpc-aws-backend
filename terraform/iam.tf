# App Runner用のIAMロール
resource "aws_iam_role" "app_runner_role" {
  name = "app-runner-todo-api"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# ECRアクセス用のIAMポリシー
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "AppRunnerECRAccessPolicy"
  description = "Policy for App Runner to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# ロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "app_runner_ecr_policy_attachment" {
  role       = aws_iam_role.app_runner_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}