# App Runnerサービスに関する出力変数
output "app_runner_service_arn" {
  description = "App Runnerサービスのarn"
  value       = aws_apprunner_service.app_service.arn
}

output "app_runner_service_url" {
  description = "App Runnerサービスのurl"
  value       = aws_apprunner_service.app_service.service_url
}

output "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.app_runner_repo.repository_url
}

output "aws_region" {
  description = "使用中のAWSリージョン"
  value       = "ap-northeast-1"
}