# ECR リポジトリを作成
resource "aws_ecr_repository" "api_repo" {
  name                 = "${local.project_name}-api-repo"
  force_delete         = true      # リポジトリを削除するときに、リポジトリ内のイメージも削除する
  image_tag_mutability = "MUTABLE" # 一度保存したコンテナイメージを上書きできるようにする

  image_scanning_configuration {
    scan_on_push = true # コンテナイメージを保存するたびにセキュリティスキャンを実行する
  }
}