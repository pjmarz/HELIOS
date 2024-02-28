#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/docker-container-rebuild.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to check the status of the last command and log an error if it failed
check_status() {
    if [ $? -ne 0 ]; then
        log "Error with command: $1"
        exit 1
    fi
}

# Start a new log session with a timestamp
log "--------------------------"
log "Rebuild started at $(date)"
log "--------------------------"

# Function to process docker-compose for a given directory
process_docker_compose() {
    log "Processing $1..."
    cd "$1"
    check_status "cd to $1"

    # Stop the containers defined in docker-compose.yml
    docker compose down 2>&1 | tee -a "$LOG_FILE"
    check_status "docker compose down in $1"

    # Pull down the latest images
    docker compose pull 2>&1 | tee -a "$LOG_FILE"
    check_status "docker compose pull in $1"

    # Start the containers in detached mode
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    check_status "docker compose up in $1"
}

# Navigate to Console Command Center directory and process docker-compose
process_docker_compose "/home/peter/Documents/dev/HELIOS/Console Command Center"

# Navigate to Media Management Center directory and process docker-compose
process_docker_compose "/home/peter/Documents/dev/HELIOS/Media Management Center"

# Clean up any unused images, containers, networks, and volumes
docker system prune -af 2>&1 | tee -a "$LOG_FILE"
check_status "docker system prune"

log "Rebuild completed successfully at $(date)"
