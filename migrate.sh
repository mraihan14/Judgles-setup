#!/bin/bash

COMPOSE_NETWORK=judgels-compose_judgels-net

echo "Running Judgels Server migration...";

docker run --rm \
    --name judgels-server-migrate \
    --network "$COMPOSE_NETWORK" \
    -v "./conf/judgels-server.yml:/judgels/server/var/conf/judgels-server.yml" \
    -v "./logs/judgels-server.log:/judgels/server/var/log/judgels-server.log" \
    ghcr.io/ia-toki/judgels/server:latest \
    db migrate
