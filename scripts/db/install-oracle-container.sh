#!/bin/bash
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

# Check if container exists
if [ "$(docker ps -a -q -f name=^/${NAME}$)" ]; then
    echo "Container $NAME already exists."
    if [ "$(docker ps -q -f name=^/${NAME}$)" ]; then
        echo "Container $NAME is already running."
    else
        echo "Starting existing container $NAME..."
        docker start $NAME
    fi
else
    echo "Creating and starting new container $NAME..."
    docker run -d --name $NAME -p 1521:1521 -p 5500:5500 -e ORACLE_PWD=$ORACLE_PWD container-registry.oracle.com/database/express:latest
fi

