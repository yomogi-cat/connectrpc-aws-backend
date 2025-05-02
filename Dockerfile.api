# ビルドステージ
FROM node:23-alpine AS build

WORKDIR /app

# パッケージファイルをコピー
COPY package*.json ./
COPY tsconfig.json ./

# 依存関係をインストール
RUN npm ci

# ソースコードをコピー
COPY src/ ./src/

# TypeScriptをビルド
RUN npm run build

# 実行ステージ
FROM node:23-alpine

WORKDIR /app

# 本番環境の依存関係のみをインストール
COPY package*.json ./
RUN npm ci --omit=dev

# ビルドステージからビルド済みのコードをコピー
COPY --from=build /app/dist ./dist

# アプリケーションを実行
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "dist/index.js"]
