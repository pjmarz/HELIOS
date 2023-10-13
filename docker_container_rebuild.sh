#!/bin/bash

# Function to check the status of the last command and display an error
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error with command: $1"
    fi
}

# Navigate to the directory containing your docker-compose.yml file
cd /home/peter/Documents/dev/HELIOS/

# Stop the containers defined in docker-compose.yml
docker compose down
check_status "docker compose down"

# Pull down the latest images
docker compose pull
check_status "docker compose pull"

# Clean up any unused images, containers, networks, and volumes
docker system prune -af
check_status "docker system prune"

# Start the containers in detached mode
docker compose up -d
check_status "docker compose up"

# Check if docker-compose up was successful
if [ $? -eq 0 ]; then
    echo "Update successful!"
else
    echo "Update failed!"
fi
