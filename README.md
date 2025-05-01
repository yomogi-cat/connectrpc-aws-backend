# App Runner ConnectRPC API

App Runner を使用して AWS にデプロイされる API サービスです。ConnectRPC を利用した API を実装しています。

## 前提条件

このプロジェクトを構築・実行するには以下が必要です：

### ローカル開発環境（開発時）

- **Node.js**: v23.7.0
- **npm**: 10.9.2
- **TypeScript**: v5.8.3
- **Docker**: Docker version 28.0.4
- **Git**: git version 2.47.1.windows.2

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
    └── server.ts      # サーバー設定
```

詳細は `ARCHITECTURE.md` を参照してください。

## 使用技術

- **Fastify**: Web フレームワーク
- **ConnectRPC**: API プロトコル (gRPC-Web 互換)
- **Protocol Buffers**: API の型定義
- **TypeScript**: 型安全な JavaScript
- **AWS App Runner**: デプロイ先
- **Terraform**: インフラストラクチャ管理
- **Docker**: コンテナ化

## 開発方法

### ローカル環境のセットアップ

```bash
# リポジトリのクローン
git clone <repository-url>
cd apprunner-api

# 依存関係のインストール
npm install

# 開発サーバーの起動
npm run dev
```

サーバーは http://localhost:3000 で起動します。

### API テスト

ヘルスチェックエンドポイント:

```bash
curl http://localhost:3000/health
```

### デプロイ方法

詳細なデプロイ手順は `DEPLOY.md` を参照してください。

```bash
# 基本的なデプロイ手順
terraform -chdir=terraform init
terraform -chdir=terraform apply -target=aws_ecr_repository.app_runner_repo

# ECR の URL を取得
export ECR_REPO_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)
export AWS_REGION=$(terraform -chdir=terraform output -raw aws_region)

# Docker イメージのビルドとプッシュ
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL
docker build -t $ECR_REPO_URL:latest .
docker push $ECR_REPO_URL:latest

# App Runner サービスのデプロイ
terraform -chdir=terraform apply
```
