#!/bin/bash

# Source the environment variables
source /root/HELIOS/env.sh

# Define paths
LOG_FILE="/root/HELIOS/script_logs/clean-usenet.log"

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$@"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Define the Docker Compose project directory
DOCKER_COMPOSE_DIR="/root/HELIOS/Media Management Center"

# Define the base directories for incomplete and completed downloads
INCOMPLETE_DIR="/mnt/usenet/incomplete"
COMPLETE_DIR="/mnt/usenet/complete"

# List of folders to clear within the completed directory (now including "default")
FOLDERS=("default" "movies" "tv")

# Log the start of the script
log "Starting clean-usenet.sh..."

# Stop sabnzbd service
log "Stopping sabnzbd service"
(cd "$DOCKER_COMPOSE_DIR" && docker compose stop sabnzbd)

# Safeguard against accidental deletion
if [[ ! -d "$INCOMPLETE_DIR" || ! -d "$COMPLETE_DIR" ]]; then
    log "ERROR: One or more directories do not exist. Exiting to prevent accidental deletion."
    exit 1
fi

# Delete all contents of the incomplete directory
log "Deleting all contents of $INCOMPLETE_DIR"
if rm -rf "${INCOMPLETE_DIR:?}"/*; then
    log "Successfully cleared $INCOMPLETE_DIR."
else
    log "Failed to clear $INCOMPLETE_DIR. Check permissions."
fi

# Loop through each folder in the completed directory and delete its contents
for folder in "${FOLDERS[@]}"; do
    TARGET_DIR="$COMPLETE_DIR/$folder"
    if [[ -d "$TARGET_DIR" ]]; then
        log "Deleting contents of $TARGET_DIR"
        if rm -rf "${TARGET_DIR:?}"/*; then
            log "Successfully cleared $TARGET_DIR."
        else
            log "Failed to clear $TARGET_DIR. Check permissions."
        fi
    else
        log "WARNING: Directory $TARGET_DIR does not exist. Skipping."
    fi
done

log "All specified folders, including the incomplete directory, have been cleared."

# Restart sabnzbd service
log "Restarting sabnzbd service"
if (cd "$DOCKER_COMPOSE_DIR" && docker compose up -d sabnzbd); then
    log "sabnzbd service restarted successfully."
else
    log "Failed to restart sabnzbd service. Check Docker Compose logs."
fi

# Notify end of script and log file location
log "Script completed. Log file is located at $LOG_FILE"
