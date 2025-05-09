# インフラ構成図

![](architecture.drawio)

# 追加したい

- Route53
- DB の連携
  - RDS
  - DynamoDB
  - 外部 DB（supabase, firestore, etc...）

# App Runner ConnectRPC API + ECS Scheduled Tasks Batch Server

- App Runner
  - バックエンド API
- ECS Scheduled Tasks
  - バッチサーバー

AWS 上に展開できるテンプレートプロジェクトです。

## 前提条件

このプロジェクトを構築・実行するには以下が必要です：

### ローカル開発環境（開発時）

- **Node.js**: v23.7.0
- **npm**: 10.9.2
- **TypeScript**: v5.8.3
- **Docker**: Docker version 28.0.4
- **Git**: git version 2.47.1.windows.2
- **Buf CLI**: 1.50.0

### AWS デプロイ用

- **AWS CLI**: aws-cli/2.24.18 Python/3.12.9 Windows/11 exe/AMD64
  - `aws configure` で認証情報が設定されていること
  - 必要な権限: ECR, App Runner, IAM の作成・管理権限
- **Terraform**: v1.11.4

## プロジェクト構造

オニオンアーキテクチャに基づいています：

```
src/
├── domain/            # ドメインレイヤー
│   ├── entities/      # エンティティ
│   └── interfaces/    # インターフェース
├── usecase/           # ユースケースレイヤー
│   └── services/      # アプリケーションサービス
├── infrastructure/    # インフラレイヤー
│   ├── logging/       # ロギング
│   ├── persistence/   # データアクセス
│   └── proto/         # Protobuf 生成コード
└── interfaces/        # インターフェースレイヤー
    ├── api/           # API 実装
    └── batch/         # バッチ実装
```

詳細は `ARCHITECTURE.md` を参照してください。

## 使用技術

- **Fastify**: Web フレームワーク
- **ConnectRPC**: API プロトコル (gRPC-Web 互換)
- **Protocol Buffers**: API の型定義
- **TypeScript**: 型安全な JavaScript
- **AWS App Runner**: デプロイ先（ConnectRPC API）
- **ECS Scheduled Tasks**: デプロイ先（Batch Server）
- **Terraform**: インフラストラクチャ管理
- **Docker**: コンテナ化

## 開発方法

### ローカル環境のセットアップ

```bash
# リポジトリのクローン
git clone https://github.com/yomogi-cat/connectrpc-aws-backend.git
cd connectrpc-aws-backend

# 依存関係のインストール
npm install

# 開発サーバーの起動
npm run api:dev
```

サーバーは http://localhost:3000 で起動します。

### API テスト

ヘルスチェックエンドポイント:

```bash
curl http://localhost:3000/health
```

### バッチ追加時

- `src/interfaces/batch/handlers` にカテゴリ分けをして Handler を作成。
  例）

  - user に関するバッチ　 ➡ 　 UserHandler
  - todo に関するバッチ　 ➡ 　 TodoHandler
    - batchRunner にコマンドによってどの handler のメソッドを呼び出すか、処理を追加する

- `ecs_task.tf`にタスク定義を追加
- `eventbridge_scheduler.tf`にスケジュールルールとターゲットを定義
- `iam.tf`の`scheduler_policy`の`Resource`に`ecs_task.tf`に追加したタスク定義を追加

### デプロイ方法

詳細なデプロイ手順は `DEPLOY.md` を参照してください。

```bash
# 基本的なデプロイ手順
terraform -chdir=terraform/modules/api init
terraform -chdir=terraform/modules/batch init

terraform -chdir=terraform/modules/api apply -target=aws_ecr_repository.api_repo
terraform -chdir=terraform/modules/batch apply -target=aws_ecr_repository.batch_repo

# ECR の URL を取得
export ECR_API_REPO_URL=$(terraform -chdir=terraform/modules/api output -raw ecr_repository_url)
export ECR_BATCH_REPO_URL=$(terraform -chdir=terraform/modules/batch output -raw ecr_repository_url)

# Docker イメージのビルドとプッシュ
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ECR_API_REPO_URL
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ECR_BATCH_REPO_URL
docker build -f Dockerfile.api -t $ECR_API_REPO_URL:latest .
docker build -f Dockerfile.batch -t $ECR_BATCH_REPO_URL:latest .
docker push $ECR_API_REPO_URL:latest
docker push $ECR_BATCH_REPO_URL:latest

# App Runner サービスのデプロイ
terraform -chdir=terraform/modules/api apply
terraform -chdir=terraform/modules/batch apply
```
