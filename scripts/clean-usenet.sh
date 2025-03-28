#!/bin/bash

# Exit on error
set -e

# Script Description
# Cleans Usenet download directories by removing contents of incomplete and completed folders

# Get the script's directory path and the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELIOS_ROOT="$(dirname "$SCRIPT_DIR")"

# Source environment variables
ENV_FILE="${HELIOS_ROOT}/env.sh"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Environment file $ENV_FILE not found. Exiting."
    exit 1
fi

# Configuration
MEDIA_DEPLOYMENT="${HELIOS_ROOT}/deployments/media"
INCOMPLETE_DIR="${DOWNLOADS_DIR}/incomplete"
COMPLETE_DIR="${DOWNLOADS_DIR}/complete"

# Define specific folders to clean in the complete directory
FOLDERS=("movies" "tv" "other")

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

# Validate paths to ensure they exist
if [[ ! -d "$HELIOS_ROOT" ]]; then
    log "HELIOS root directory not found at $HELIOS_ROOT"
    exit 1
fi

if [[ ! -d "$MEDIA_DEPLOYMENT" ]]; then
    log "Media deployment directory not found at $MEDIA_DEPLOYMENT"
    exit 1
fi

# Stop sabnzbd service before cleaning directories
log "Stopping sabnzbd service"
(cd "$MEDIA_DEPLOYMENT" && docker compose stop sabnzbd) || {
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
(cd "$MEDIA_DEPLOYMENT" && docker compose up -d sabnzbd) || {
    log "Failed to restart sabnzbd service"
    exit 1
}

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
