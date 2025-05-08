output "ecr_repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.batch_repo.repository_url
}

output "aws_region" {
  description = "使用中のAWSリージョン"
  value       = "ap-northeast-1"
  depends_on = [
    aws_ecr_repository.batch_repo
  ]
}