#!/bin/bash
set -e

NAME="vagrant-dev"

echo "🚀 Развертывание Hexlet ДЗ..."

# VM
if ! multipass info $NAME >/dev/null 2>&1; then
  echo "Создаём VM..."
  multipass launch 24.04 --name $NAME --cpus 2 --memory 4G
  multipass set local.privileged-ports=true $NAME
  multipass mount . $NAME:/vagrant
fi

# Развертывание
multipass exec $NAME -- bash -c "
  apt-get update
  apt-get install -y curl postgresql postgresql-contrib make git
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
  sudo -u postgres createuser -s ubuntu
  sudo -u postgres createdb vagrant
  cd /vagrant
  git clone https://github.com/hexlet-components/js-fastify-blog.git
  cd js-fastify-blog && rm -rf .git
  npm ci
  npm run build
  nohup npm start > /vagrant/app.log 2>&1 &
"

echo "✅ Готово! curl localhost:8080"
