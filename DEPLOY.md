# Terraform による AWS App Runner デプロイガイド

このガイドでは、Terraform を使用して AWS App Runner サービスを構築し、コンテナアプリケーションをデプロイする手順を説明します。

## 前提条件

- AWS アカウント
- AWS CLI がインストール済みで、適切な権限をもつプロファイルが設定されていること
- Terraform がインストール済み（v1.11.4 以上を推奨）
- Docker がインストール済み

## 目次

1. [Terraform コードの作成](#1-terraform-コードの作成)
2. [Terraform の実行 - ECR リポジトリ作成](#2-terraform-の実行---ecrリポジトリ作成)
3. [Docker イメージのビルドとプッシュ](#3-docker-イメージのビルドとプッシュ)
4. [Terraform の実行 - App Runner 作成](#4-terraform-の実行---app-runner作成)
5. [デプロイの確認](#5-デプロイの確認)
6. [クリーンアップ](#6-クリーンアップ)

## 1. Terraform コードの作成

以下の Terraform ファイルを作成します。

### プロバイダー設定

| ファイル名  | リソース名 | 説明                 | 主要な設定                                                                    |
| ----------- | ---------- | -------------------- | ----------------------------------------------------------------------------- |
| provider.tf | aws        | AWS プロバイダー設定 | リージョン: ap-northeast-1<br>デフォルトタグ: Project=app-runner-todo-api     |
| provider.tf | terraform  | Terraform 設定       | AWS プロバイダーバージョン: ~> 5.96.0<br>必須 Terraform バージョン: >= 1.11.4 |

### インフラストラクチャリソース

| ファイル名   | リソース名                                       | 説明                   | 主要な設定                                                                                     |
| ------------ | ------------------------------------------------ | ---------------------- | ---------------------------------------------------------------------------------------------- |
| appRunner.tf | aws_apprunner_service                            | App Runner サービス    | サービス名: app-runner-todo-api<br>ポート: 3000<br>CPU: 1024<br>メモリ: 2048MB                 |
| appRunner.tf | aws_apprunner_auto_scaling_configuration_version | 自動スケーリング設定   | 最大同時実行数: 50<br>最大インスタンス数: 5<br>最小インスタンス数: 1                           |
| ecr.tf       | aws_ecr_repository                               | ECR リポジトリ         | リポジトリ名: app-runner-todo-api<br>イメージタグ変更可能: MUTABLE<br>プッシュ時スキャン: 有効 |
| iam.tf       | aws_iam_role                                     | IAM ロール             | ロール名: app-runner-todo-api<br>信頼ポリシー: build.apprunner.amazonaws.com                   |
| iam.tf       | aws_iam_policy                                   | ECR アクセスポリシー   | ポリシー名: AppRunnerECRAccessPolicy<br>ECR 操作権限: 完全アクセス                             |
| iam.tf       | aws_iam_role_policy_attachment                   | ポリシーアタッチメント | ロールとポリシーの関連付け                                                                     |

### 出力変数

| ファイル名 | 出力名                 | 説明                      | 値                                                |
| ---------- | ---------------------- | ------------------------- | ------------------------------------------------- |
| outputs.tf | app_runner_service_arn | App Runner サービスの ARN | aws_apprunner_service.app_service.arn             |
| outputs.tf | app_runner_service_url | App Runner サービスの URL | aws_apprunner_service.app_service.service_url     |
| outputs.tf | ecr_repository_url     | ECR リポジトリの URL      | aws_ecr_repository.app_runner_repo.repository_url |
| outputs.tf | aws_region             | AWS リージョン            | ap-northeast-1                                    |

## 2. Terraform の実行 - ECR リポジトリ作成

App Runner は空の ECR リポジトリを参照するとデプロイに失敗するため、
最初に ECR リポジトリのみを作成します。

```bash
# Terraform の初期化
terraform -chdir=terraform init

# 実行計画の確認（ECRリポジトリのみ）
terraform -chdir=terraform plan -target=aws_ecr_repository.app_runner_repo

# ECRリポジトリの作成（確認メッセージが表示されたら「yes」と入力）
terraform -chdir=terraform apply -target=aws_ecr_repository.app_runner_repo

# 出力値を環境変数に設定
export ECR_REPO_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)
export AWS_REGION=$(terraform -chdir=terraform output -raw aws_region)
```

## 3. Docker イメージのビルドとプッシュ

アプリケーションの Docker イメージをビルドして ECR リポジトリにプッシュします。

```bash
# ECR へのログイン
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL

# Docker イメージのビルド
docker build -t $ECR_REPO_URL:latest .

# イメージのプッシュ
docker push $ECR_REPO_URL:latest
```

## 4. Terraform の実行 - App Runner 作成

ECR にイメージがプッシュされたら、App Runner サービスを作成します。

```bash
# App Runnerおよび関連リソースの作成
terraform -chdir=terraform apply

# 出力値を環境変数に設定
export APP_RUNNER_ARN=$(terraform -chdir=terraform output -raw app_runner_service_arn)
```

## 5. デプロイの確認

App Runner サービスのデプロイ状況を確認します。

```bash
# デプロイステータスの確認
aws apprunner describe-service --service-arn $APP_RUNNER_ARN --region $AWS_REGION

# サービスの URL を取得
export APP_RUNNER_URL=$(terraform -chdir=terraform output -raw app_runner_service_url)
echo "App Runner URL: https://$APP_RUNNER_URL"

# ヘルスチェックエンドポイントへのアクセス
curl -v https://$APP_RUNNER_URL/health
```

デプロイが完了するまで数分かかる場合があります。AWS コンソールの App Runner ダッシュボードでも進行状況を確認できます。

## 6. クリーンアップ

使用後はリソースを削除してコストを抑えることができます。

```bash
# Terraform リソースの削除
terraform -chdir=terraform destroy

# 確認メッセージが表示されたら「yes」と入力
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

このガイドでは、Terraform を使用して AWS App Runner サービスを構築し、コンテナアプリケーションをデプロイする方法を説明しました。必要に応じて設定をカスタマイズし、本番環境のニーズに合わせて調整してください。
