output "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.api_repo.repository_url
}