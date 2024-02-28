#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define the log file
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/restart-docker.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to log a message with a timestamp
log_message() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Start a new log session with a timestamp
log_message "Starting the Docker restart process..."

# Check Docker service status
log_message "Checking Docker service status..."
if systemctl is-active --quiet docker; then
    log_message "Docker is active."
else
    log_message "Docker is not active. Attempting to start..."
    sudo systemctl start docker
    if [ $? -ne 0 ]; then
        log_message "Error starting Docker service. Exiting."
        exit 1
    fi
fi

# Restart Docker service
log_message "Restarting Docker service..."
sudo systemctl restart docker
if [ $? -ne 0 ]; then
    log_message "Error restarting Docker service. Exiting."
    exit 1
fi

# Function to restart docker-compose in a specific directory
restart_docker_compose() {
    local directory="$1"
    log_message "Navigating to ${directory}..."
    cd "$directory"
    if [ $? -ne 0 ]; then
        log_message "Error navigating to ${directory}. Exiting."
        exit 1
    fi

    log_message "Running docker compose up in detached mode..."
    docker compose up -d
    if [ $? -ne 0 ]; then
        log_message "Error running docker compose up in ${directory}. Exiting."
        exit 1
    fi

    log_message "Checking Docker Compose services status in ${directory}..."
    docker compose ps | tee -a "$LOG_FILE"
}

# Restart docker-compose for Console Command Center
restart_docker_compose "/home/peter/Documents/dev/HELIOS/Console Command Center"

# Restart docker-compose for Media Management Center
restart_docker_compose "/home/peter/Documents/dev/HELIOS/Media Management Center"

log_message "Docker restart process completed!"
