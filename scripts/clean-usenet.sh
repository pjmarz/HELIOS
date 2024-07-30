#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/clean-usenet.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Define the Docker Compose project directory
DOCKER_COMPOSE_DIR="/home/peter/Documents/dev/HELIOS/Media Management Center"

# Log the start of the script
log "Starting clean-usenet.sh..."

# Stop sabnzbd service
log "Stopping sabnzbd service"
(cd "$DOCKER_COMPOSE_DIR" && docker compose stop sabnzbd)

# Define the base directory for incomplete and completed downloads
INCOMPLETE_DIR="/mnt/LOAS/usenet/incomplete"
COMPLETE_DIR="/mnt/LOAS/usenet/complete"

# Delete all contents of the incomplete directory
log "Deleting all contents of $INCOMPLETE_DIR"
rm -rf "${INCOMPLETE_DIR:?}"/*

# List of folders to clear within the completed directory
FOLDERS=("default" "movies" "tv" "xxx")

# Loop through each folder in the complete directory and delete its contents
for folder in "${FOLDERS[@]}"
do
    log "Deleting contents of $COMPLETE_DIR/$folder"
    rm -rf "${COMPLETE_DIR:?}/${folder:?}"/*
done

log "All specified folders, including the incomplete directory, have been cleared."

# Restart sabnzbd service
log "Restarting sabnzbd service"
(cd "$DOCKER_COMPOSE_DIR" && docker compose up -d sabnzbd)

# Notify end of script and log file location
log "Script completed. Log file is located at $LOG_FILE"
