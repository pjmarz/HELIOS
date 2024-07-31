#!/bin/bash

# Load environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define the paths to the directories containing your docker-compose files
console_command_center_path="/home/peter/Documents/dev/HELIOS/Console Command Center"
media_management_center_path="/home/peter/Documents/dev/HELIOS/Media Management Center"
tesla_management_center_path="/home/peter/Documents/dev/HELIOS/Tesla Management Center"

# Define the log file
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/master-compose-up.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to run docker-compose up in a directory and log the output
run_docker_compose_up() {
    log "Starting docker-compose up in $1..."
    docker compose -f "$1/docker-compose.yml" up -d 2>&1 | tee -a "$LOG_FILE"
    log "docker-compose up finished in $1"
}

# Run docker-compose up -d in all directories and log the output
run_docker_compose_up "$console_command_center_path" &
run_docker_compose_up "$media_management_center_path" &
run_docker_compose_up "$tesla_management_center_path" &

# Wait for all background processes to finish
wait
log "All docker-compose services are up and running."
