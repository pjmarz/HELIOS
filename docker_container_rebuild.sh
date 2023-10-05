#!/bin/bash

# Function to check the status of the last command and display an error
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error with command: $1"
    fi
}

# Stop all running containers
docker stop $(docker ps -a -q)
check_status "docker stop"

# Remove all stopped containers
docker rm $(docker ps -a -q)
check_status "docker rm"

# Pull down the latest images
docker compose pull
check_status "docker compose pull"

# Clean up any leftovers
docker rmi $(docker images -q -f dangling=true)
check_status "docker rmi"

docker volume rm $(docker volume ls -qf dangling=true)
check_status "docker volume rm"

docker network prune -f
check_status "docker network prune"

docker builder prune -f
check_status "docker builder prune"

docker system prune -af
check_status "docker system prune"

# Run docker compose up in detached mode
docker compose up -d
check_status "docker compose up"

# Check if docker-compose up was successful
if [ $? -eq 0 ]; then
    echo "Update successful!"
else
    echo "Update failed!"
fi
