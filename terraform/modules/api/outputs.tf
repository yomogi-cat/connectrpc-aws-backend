output "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.app_runner_repo.repository_url
}