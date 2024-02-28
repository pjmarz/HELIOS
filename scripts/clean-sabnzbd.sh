#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/clean-sabnzbd.log"

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
log "Starting new script run"

# Stop sabnzbd service
log "Stopping sabnzbd service"
(cd "$DOCKER_COMPOSE_DIR" && docker compose stop sabnzbd)

# Define the base directory for completed downloads
BASE_DIR="/mnt/CHARON/sabnzbd/downloads/completed"

# Define the intermediate directory
INTERMEDIATE_DIR="/mnt/CHARON/sabnzbd/downloads/intermediate"

# Delete all contents of the intermediate directory
log "Deleting all contents of $INTERMEDIATE_DIR"
rm -rf "${INTERMEDIATE_DIR:?}"/*

# List of folders to clear within the completed directory
FOLDERS=("default" "movies" "tv" "xxx")

# Loop through each folder in the completed directory and delete its contents
for folder in "${FOLDERS[@]}"
do
    log "Deleting contents of $BASE_DIR/$folder"
    rm -rf "${BASE_DIR:?}/${folder:?}"/*
done

log "All specified folders, including the intermediate directory, have been cleared."

# Restart sabnzbd service
log "Restarting sabnzbd service"
(cd "$DOCKER_COMPOSE_DIR" && docker compose up -d sabnzbd)

# Notify end of script and log file location
log "Script completed. Log file is located at $LOG_FILE"
