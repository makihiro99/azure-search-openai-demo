#!/bin/bash
set -e

# cd into the parent directory of the script
cd "${0%/*}" || exit 1
cd ../

# 仮想環境がなければ作成
if [ ! -d ".venv" ]; then
    echo 'Creating python virtual environment ".venv"'
    python3 -m venv .venv
fi

# Pythonパッケージのインストール
echo ""
echo "Restoring backend python packages"
echo ""

./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install -r app/backend/requirements.txt

# フロントエンドの依存関係インストール
echo ""
echo "Restoring frontend npm packages"
echo ""

cd app/frontend
npm install

# フロントエンドのビルド
echo ""
echo "Building frontend"
echo ""

npm run build
cd ../..

# バックエンドの起動
echo ""
echo "Starting backend"
echo ""

cd app/backend

# Azure App Service では PORT 環境変数を使用する
PORT=${PORT:-8000}
HOST=0.0.0.0

../../.venv/bin/python -m quart --app main:app run --port "$PORT" --host "$HOST"
