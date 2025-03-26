#!/bin/bash

# Exit on error
set -e

# Script Description
# Cleans up usenet download directories and restarts sabnzbd service

# Source environment variables
ENV_FILE="/root/HELIOS/env.sh"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Environment file $ENV_FILE not found. Exiting."
    exit 1
fi

# Base paths
HELIOS_ROOT="/root/HELIOS"
MEDIA_CENTER="${HELIOS_ROOT}/Media Management Center"
INCOMPLETE_DIR="/mnt/usenet/incomplete"
COMPLETE_DIR="/mnt/usenet/complete"

# Logging configuration
LOG_DIR="${HELIOS_ROOT}/logs"
LOG_FILE="${LOG_DIR}/$(basename "$0" .sh).log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Initialize log file
: > "$LOG_FILE"

# Logging function
log() {
    local msg="$*"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log "Error on line $line_number: Exit code $exit_code"
    exit $exit_code
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Log script start
log "=== Script Start ==="

# List of folders to clear within the completed directory
FOLDERS=("default" "movies" "tv")

# Stop sabnzbd service
log "Stopping sabnzbd service"
(cd "$MEDIA_CENTER" && docker compose stop sabnzbd) || {
    log "Error stopping sabnzbd service"
    exit 1
}

# Safeguard against accidental deletion
if [[ ! -d "$INCOMPLETE_DIR" || ! -d "$COMPLETE_DIR" ]]; then
    log "ERROR: One or more directories do not exist. Exiting to prevent accidental deletion."
    exit 1
fi

# Delete all contents of the incomplete directory
log "Deleting all contents of $INCOMPLETE_DIR"
if rm -rf "${INCOMPLETE_DIR:?}"/*; then
    log "Successfully cleared $INCOMPLETE_DIR"
else
    log "Failed to clear $INCOMPLETE_DIR. Check permissions."
fi

# Loop through each folder in the completed directory and delete its contents
for folder in "${FOLDERS[@]}"; do
    TARGET_DIR="$COMPLETE_DIR/$folder"
    if [[ -d "$TARGET_DIR" ]]; then
        log "Deleting contents of $TARGET_DIR"
        if rm -rf "${TARGET_DIR:?}"/*; then
            log "Successfully cleared $TARGET_DIR"
        else
            log "Failed to clear $TARGET_DIR. Check permissions."
        fi
    else
        log "WARNING: Directory $TARGET_DIR does not exist. Skipping."
    fi
done

# Restart sabnzbd service
log "Restarting sabnzbd service"
(cd "$MEDIA_CENTER" && docker compose up -d sabnzbd) || {
    log "Failed to restart sabnzbd service"
    exit 1
}

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
