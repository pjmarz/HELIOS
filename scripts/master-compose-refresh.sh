#!/bin/bash

# Source the environment variables
source /root/HELIOS/env.sh

# Define the paths to the directories containing your docker-compose files
declare -a COMPOSE_DIRS=(
    "/root/HELIOS/Console Command Center"
    "/root/HELIOS/Media Management Center"
)

# Define the log file
LOG_FILE="/root/HELIOS/script_logs/master-compose-refresh.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log_message() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Function to refresh Docker Compose in a given directory
refresh_docker_compose() {
    local directory="$1"

    log_message "Starting refresh in ${directory}..."

    if [ ! -d "$directory" ]; then
        log_message "Directory ${directory} does not exist. Skipping."
        return
    fi

    cd "$directory" || {
        log_message "Failed to navigate to ${directory}. Skipping."
        return
    }

    # Bring down the Docker Compose stack
    log_message "Running docker compose down in ${directory}..."
    docker compose down 2>&1 | tee -a "$LOG_FILE"
    if [ $? -ne 0 ]; then
        log_message "Error encountered while running docker compose down in ${directory}."
        return
    fi

    # Bring up the Docker Compose stack
    log_message "Running docker compose up -d in ${directory}..."
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    if [ $? -ne 0 ]; then
        log_message "Error encountered while running docker compose up in ${directory}."
        return
    fi

    log_message "Successfully refreshed Docker Compose in ${directory}."
}

# Start the script
log_message "--------------------------"
log_message "Docker Compose Refresh Started"
log_message "--------------------------"

# Process each Docker Compose directory
for directory in "${COMPOSE_DIRS[@]}"; do
    refresh_docker_compose "$directory"
done

log_message "All specified Docker Compose stacks have been refreshed."
