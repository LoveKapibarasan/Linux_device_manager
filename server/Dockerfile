FROM node:22-alpine

WORKDIR /app

COPY shogihome/ ./

# 依存関係をインストール
RUN npm ci

EXPOSE 5173

# 開発サーバーを起動
CMD ["npm", "run", "serve", "--", "--host", "0.0.0.0"]