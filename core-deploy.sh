#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# ===== Setup Judgels Directories =====
mkdir -p ./judgels/client/var ./judgels/server/var
chmod -R 777 ./judgels

# ===== Spin up the Judgels Containers =====
docker compose up -d

# ===== Wait for containers to be up =====
echo 'Waiting for Judgels Server to start...'
sleep 5

CONTAINER_COUNT=$(docker ps --filter "name=judgels-" --filter "status=running" -q | wc -l)
EXPECTED_COUNT=5

if [ "$CONTAINER_COUNT" -lt "$EXPECTED_COUNT" ]; then
    echo '-----------------------------------------------------------------------'
    echo "WARNING: Only $CONTAINER_COUNT judgels containers are running (expected $EXPECTED_COUNT)"
    echo 'Please check the logs of the containers for more information.'
else
    echo 'Judgels Server is Up and Running!'
fi

# ===== Run Migration =====
COMPOSE_PROJECT=$(basename "$PWD")
COMPOSE_NETWORK="${COMPOSE_PROJECT}_judgels-net"

# Pastikan network ada
docker network inspect "$COMPOSE_NETWORK" >/dev/null 2>&1 || docker network create "$COMPOSE_NETWORK"

echo "Running Judgels Server migration on network: $COMPOSE_NETWORK, version: $VERSION"

docker run --rm \
    --name judgels-server-migrate \
    --network "$COMPOSE_NETWORK" \
    -v "$PWD/conf/judgels-server.yml:/judgels/server/var/conf/judgels-server.yml" \
    -v "$PWD/logs/judgels-server.log:/judgels/server/var/log/judgels-server.log" \
    ghcr.io/ia-toki/judgels/server:$VERSION \
    db migrate
