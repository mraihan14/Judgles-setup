#!/bin/bash

# Create directories for judgels client and server
mkdir -p ./judgels/client/var ./judgels/server/var
chmod -R 777 ./judgels

# Spin up the Judgels Containers
docker compose up -d

# Check if the containers are running
echo 'Waiting for Judgels Server to start...';
sleep 5
CONTAINER_COUNT=$(docker container ls | grep 'judgels-' | grep 'Up' | wc -l)
if [ "$CONTAINER_COUNT" -ne 5 ]; then
    echo '-----------------------------------------------------------------------'
    echo 'ERROR: Existing judgels containers does not match the expected count 5 containers'
    echo 'Please check the logs of the containers for more information.'
    echo 'Exiting...'
fi

echo 'Judgels Server is Up and Running!';

# Run the migration
COMPOSE_NETWORK=judgels-compose_judgels-net

echo "Running Judgels Server migration...";

docker run --rm \
    --name judgels-server-migrate \
    --network "$COMPOSE_NETWORK" \
    -v "./conf/judgels-server.yml:/judgels/server/var/conf/judgels-server.yml" \
    -v "./logs/judgels-server.log:/judgels/server/var/log/judgels-server.log" \
    ghcr.io/ia-toki/judgels/server:2.22.0 \
    db migrate
