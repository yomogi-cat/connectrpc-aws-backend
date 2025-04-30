# ECR リポジトリを作成
resource "aws_ecr_repository" "app_runner_repo" {
  name                 = "app-runner-todo-api"
  image_tag_mutability = "MUTABLE" # 一度保存したコンテナイメージを上書きできるようにする

  image_scanning_configuration {
    scan_on_push = true # コンテナイメージを保存するたびにセキュリティスキャンを実行する
  }
}