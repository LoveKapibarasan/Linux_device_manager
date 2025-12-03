FROM node:22-alpine

# Gitをインストール
RUN apk add --no-cache git

WORKDIR /app

# リポジトリをクローン
RUN git clone https://github.com/sunfish-shogi/shogihome.git .

# 依存関係をインストール
RUN npm ci

EXPOSE 5173

# 開発サーバーを起動
CMD ["npm", "run", "serve", "--", "--host", "0.0.0.0"]