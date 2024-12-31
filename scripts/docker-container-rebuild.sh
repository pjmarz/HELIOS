#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Source the environment variables
ENV_FILE="/home/peter/Documents/dev/HELIOS/env.sh"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Environment file $ENV_FILE not found. Exiting."
    exit 1
fi

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/docker-container-rebuild.log"

# Clear the log file at the beginning of the script
: > "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to process docker-compose for a given directory
process_docker_compose() {
    local dir="$1"
    log "Processing directory: $dir"

    if [ ! -d "$dir" ]; then
        log "Directory $dir does not exist. Skipping."
        return
    fi

    cd "$dir"
    log "Changed directory to $dir"

    # Stop the containers defined in docker-compose.yml
    docker compose down 2>&1 | tee -a "$LOG_FILE"
    log "Stopped containers in $dir"

    # Pull down the latest images
    docker compose pull 2>&1 | tee -a "$LOG_FILE"
    log "Pulled latest images in $dir"

    # Start the containers in detached mode
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    log "Started containers in $dir"
}

# Function to prune unused docker resources
prune_docker_system() {
    docker system prune -af 2>&1 | tee -a "$LOG_FILE"
    log "Pruned unused Docker resources"
}

# Start a new log session with a timestamp
log "--------------------------"
log "Rebuild started at $(date)"
log "--------------------------"

# Define the directories to process
DIRS=(
    "/home/peter/Documents/dev/HELIOS/Console Command Center"
    "/home/peter/Documents/dev/HELIOS/Media Management Center"
)

# Process each directory
for dir in "${DIRS[@]}"; do
    process_docker_compose "$dir"
done

# Clean up any unused images, containers, networks, and volumes
prune_docker_system

log "Rebuild completed successfully at $(date). Log file is located at $LOG_FILE"
