#!/bin/bash

BASEDIR=$(dirname "$0")

source ./$BASEDIR/.env

# clear all previous docker artifacts
./$BASEDIR/stop.sh

# creating network to run all related containers in
docker network create eschool-network

# starting container with mysql DB
docker run --name eschool-mysql \
    -p :3306 \
    --network eschool-network \
    -e MYSQL_ROOT_PASSWORD=$DATASOURCE_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -d mysql:5.6
# Чекаємо, поки MySQL буде готова
echo "⏳ Waiting for MySQL to be ready..."
until docker exec eschool-mysql mysqladmin ping -h"localhost" --silent; do
  sleep 3
  echo "Still waiting for MySQL..."
done
echo "✅ MySQL is ready."
# building app image
docker build -t backend .

# starting app container
docker run --name eschool-backend \
     --env-file ./$BASEDIR/.env \
     --network eschool-network \
     -p 8080:8080 \
     -d backend
