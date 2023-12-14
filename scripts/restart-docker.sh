#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define the log file
LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/restart-docker.log"

# Function to log a message
log_message() {
    echo "$(date) - $1" | tee -a "$LOGFILE"
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
    log_message "Navigating to $1..."
    cd "$1"
    if [ $? -ne 0 ]; then
        log_message "Error navigating to $1. Exiting."
        exit 1
    fi

    log_message "Running docker compose up in detached mode..."
    docker compose up -d
    if [ $? -ne 0 ]; then
        log_message "Error running docker compose up in $1. Exiting."
        exit 1
    fi

    log_message "Checking Docker Compose services status in $1..."
    docker compose ps | tee -a "$LOGFILE"
}

# Restart docker-compose for Console Command Center
restart_docker_compose "/home/peter/Documents/dev/HELIOS/Console Command Center"

# Restart docker-compose for Media Management Center
restart_docker_compose "/home/peter/Documents/dev/HELIOS/Media Management Center"

log_message "Docker restart process completed!"
