output "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.batch_repo.repository_url
}