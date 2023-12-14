#!/bin/bash

# Load environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define the paths to the directories containing your docker-compose files
console_command_center_path="/home/peter/Documents/dev/HELIOS/Console Command Center"
media_management_center_path="/home/peter/Documents/dev/HELIOS/Media Management Center"

# Define the log file
LOGFILE="/home/peter/Documents/dev/HELIOS/script_logs/master-compose-up.log"

# Function to run docker-compose up in a directory and log the output
run_docker_compose_up() {
    echo "Starting docker-compose up in $1..." | tee -a "$LOGFILE"
    docker compose -f "$1/docker-compose.yml" up -d | tee -a "$LOGFILE"
    echo "docker-compose up finished in $1" | tee -a "$LOGFILE"
}

# Run docker-compose up -d in both directories and log the output
run_docker_compose_up "$console_command_center_path" &
run_docker_compose_up "$media_management_center_path" &

# Wait for all background processes to finish
wait
echo "All docker-compose services are up and running." | tee -a "$LOGFILE"
