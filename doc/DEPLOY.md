# Terraform による AppRunner + ECS Scheduled Tasks デプロイガイド

このガイドでは、Terraform を使用して AppRunner + ECS Scheduled Tasks サービスを構築し、
コンテナアプリケーションをデプロイする手順を説明します。

## 前提条件

- AWS アカウント
- AWS CLI がインストール済みで、適切な権限をもつプロファイルが設定されていること
- Terraform がインストール済み（v1.11.4 以上を推奨）
- Docker がインストール済み

## 目次

1. [Terraform の実行 - ECR リポジトリ作成](#1-terraform-の実行---ecrリポジトリ作成)
2. [Docker イメージのビルドとプッシュ](#2-docker-イメージのビルドとプッシュ)
3. [Terraform の実行 - App Runner 作成](#3-terraform-の実行---app-runner作成)
4. [デプロイの確認](#4-デプロイの確認)
5. [Terraform の実行 - バッチ 作成](#5-terraform-の実行---バッチ作成)
6. [Docker イメージのビルドとプッシュ](#6-docker-イメージのビルドとプッシュ)
7. [クリーンアップ](#7-クリーンアップ)

## 1. Terraform の実行 - ECR リポジトリ作成

App Runner は空の ECR リポジトリを参照するとデプロイに失敗するため、
最初に ECR リポジトリのみを作成します。

```bash
# Terraform の初期化
terraform -chdir=terraform/modules/api init

# 実行計画の確認（ECRリポジトリのみ）
terraform -chdir=terraform/modules/api plan -target=aws_ecr_repository.api_repo

# ECRリポジトリの作成（確認メッセージが表示されたら「yes」と入力）
terraform -chdir=terraform/modules/api apply -target=aws_ecr_repository.api_repo

# 出力値を環境変数に設定
export ECR_API_REPO_URL=$(terraform -chdir=terraform/modules/api output -raw ecr_repository_url)
```

## 2. Docker イメージのビルドとプッシュ

アプリケーションの Docker イメージをビルドして ECR リポジトリにプッシュします。

```bash
# ECR へのログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ECR_API_REPO_URL

# Docker イメージのビルド
docker build -t $ECR_API_REPO_URL:latest .

# イメージのプッシュ
docker push $ECR_API_REPO_URL:latest
```

## 3. Terraform の実行 - App Runner 作成

ECR にイメージがプッシュされたら、App Runner サービスを作成します。

```bash
# App Runnerおよび関連リソースの作成
terraform -chdir=terraform/modules/api apply

# 出力値を環境変数に設定
export APP_RUNNER_ARN=$(terraform -chdir=terraform/modules/api output -raw app_runner_service_arn)
```

## 4. デプロイの確認

App Runner サービスのデプロイ状況を確認します。

```bash
# デプロイステータスの確認
aws apprunner describe-service --service-arn $APP_RUNNER_ARN --region ap-northeast-1

# サービスの URL を取得
export APP_RUNNER_URL=$(terraform -chdir=terraform/modules/api output -raw app_runner_service_url)

# ヘルスチェックエンドポイントへのアクセス
curl -v https://$APP_RUNNER_URL/health
```

デプロイが完了するまで数分かかる場合があります。
AWS コンソールの App Runner ダッシュボードでも進行状況を確認できます。

## 5. Terraform の実行 - バッチ 作成

```bash
# Terraform の初期化
terraform -chdir=terraform/modules/batch init

# 実行計画の確認（ECRリポジトリのみ）
terraform -chdir=terraform/modules/batch plan

# ECRリポジトリの作成（確認メッセージが表示されたら「yes」と入力）
terraform -chdir=terraform/modules/batch apply

# 出力値を環境変数に設定
export ECR_BATCH_REPO_URL=$(terraform -chdir=terraform/modules/batch output -raw ecr_repository_url)
```

## 6. Docker イメージのビルドとプッシュ

アプリケーションの Docker イメージをビルドして ECR リポジトリにプッシュします。

```bash
# ECR へのログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ECR_BATCH_REPO_URL

# Docker イメージのビルド
docker build -t $ECR_BATCH_REPO_URL:latest .

# イメージのプッシュ
docker push $ECR_BATCH_REPO_URL:latest
```

## 7. クリーンアップ

使用後はリソースを削除してコストを抑えることができます。

```bash
# Terraform リソースの削除
terraform -chdir=terraform/modules/api destroy
terraform -chdir=terraform/modules/batch destroy
```

## トラブルシューティング

### デプロイが失敗する場合

- App Runner ログで詳細なエラーメッセージを確認
- ヘルスチェックエンドポイント（/health）がアプリケーションで正しく実装されているか確認
- IAM ロールとポリシーの権限が正しく設定されているか確認

### イメージのプッシュに失敗する場合

- AWS CLI の認証情報が正しく設定されているか確認
- ECR リポジトリに対する適切な権限があるか確認
- 以下参照
  https://zenn.dev/kuritify/articles/docker-descktop-setting-from-ecr-400-bad-request

### アプリケーションにアクセスできない場合

- App Runner サービスのステータスが「Running」になっているか確認
- ヘルスチェックが成功しているか確認
- コンテナポートが正しく設定されているか確認

---
