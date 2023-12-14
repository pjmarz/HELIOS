#!/bin/bash

# Define the log file with a fixed name
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/docker-container-rebuild.log"

# Function to check the status of the last command and display an error
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error with command: $1" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Function to log a message
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Start a new log session with a timestamp
echo "--------------------------" | tee -a "$LOG_FILE"
echo "Rebuild started at $(date)" | tee -a "$LOG_FILE"
echo "--------------------------" | tee -a "$LOG_FILE"

# Load environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Function to process docker-compose for a given directory
process_docker_compose() {
    log_message "Processing $1..."
    cd "$1"
    check_status "cd to $1"

    # Stop the containers defined in docker-compose.yml
    docker compose down | tee -a "$LOG_FILE"
    check_status "docker compose down in $1"

    # Pull down the latest images
    docker compose pull | tee -a "$LOG_FILE"
    check_status "docker compose pull in $1"

    # Start the containers in detached mode
    docker compose up -d | tee -a "$LOG_FILE"
    check_status "docker compose up in $1"
}

# Navigate to Console Command Center directory and process docker-compose
process_docker_compose "/home/peter/Documents/dev/HELIOS/Console Command Center"

# Navigate to Media Management Center directory and process docker-compose
process_docker_compose "/home/peter/Documents/dev/HELIOS/Media Management Center"

# Clean up any unused images, containers, networks, and volumes
docker system prune -af | tee -a "$LOG_FILE"
check_status "docker system prune"

log_message "Rebuild completed successfully at $(date)"
