#!/bin/bash

# Source the environment variables
source /root/HELIOS/env.sh

# Define the paths to the directories containing your docker-compose files
console_command_center_path="/root/HELIOS/Console Command Center"
media_management_center_path="/root/HELIOS/Media Management Center"

# Define the log file
LOG_FILE="/root/HELIOS/logs/master-compose-down.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to run docker-compose down in a directory and log the output
run_docker_compose_down() {
    log "Starting docker-compose down in $1..."
    docker compose -f "$1/docker-compose.yml" down 2>&1 | tee -a "$LOG_FILE"
    if [ $? -eq 0 ]; then
        log "docker-compose down finished successfully in $1"
    else
        log "Error encountered while running docker-compose down in $1"
    fi
}

# Run docker-compose down in all directories and log the output
run_docker_compose_down "$console_command_center_path" &
run_docker_compose_down "$media_management_center_path" &

# Wait for all background processes to finish
wait
log "All docker-compose services have been stopped and cleaned up."
