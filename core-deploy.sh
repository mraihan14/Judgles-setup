#!/bin/bash

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

mkdir -p ./judgels/client/var ./judgels/server/var logs
touch logs/judgels-server.log
chmod -R 777 ./judgels logs

docker compose up -d

echo 'Waiting for Judgels Server to start...'
sleep 5

CONTAINER_COUNT=$(docker ps --filter "name=judgels-" --filter "status=running" -q | wc -l)
EXPECTED_COUNT=5

if [ "$CONTAINER_COUNT" -lt "$EXPECTED_COUNT" ]; then
    echo "WARNING: Only $CONTAINER_COUNT judgels containers are running (expected $EXPECTED_COUNT)"
else
    echo 'Judgels Server is Up and Running!'
fi

COMPOSE_PROJECT=$(basename "$PWD")
COMPOSE_NETWORK="judgels-compose_judgels-net"

docker network inspect "$COMPOSE_NETWORK" >/dev/null 2>&1 || docker network create "$COMPOSE_NETWORK"

echo "Waiting 20s for MySQL to be ready..."
sleep 20

docker run --rm \
    --name judgels-server-migrate \
    --network "$COMPOSE_NETWORK" \
    -v "$PWD/conf/judgels-server.yml:/judgels/server/var/conf/judgels-server.yml" \
    -v "$PWD/logs/judgels-server.log:/judgels/server/var/log/judgels-server.log" \
    ghcr.io/ia-toki/judgels/server:$VERSION \
    db migrate
