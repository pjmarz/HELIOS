#!/bin/bash

# Exit on error
set -e

# Script Description
# Refreshes all Docker Compose services by stopping and starting them

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
CONSOLE_CENTER="${HELIOS_ROOT}/Console Command Center"
MEDIA_CENTER="${HELIOS_ROOT}/Media Management Center"

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

# Function to refresh Docker Compose in a given directory
refresh_docker_compose() {
    local directory="$1"

    log "Starting refresh in ${directory}..."

    if [ ! -d "$directory" ]; then
        log "Directory ${directory} does not exist. Skipping."
        return 1
    fi

    cd "$directory" || {
        log "Failed to navigate to ${directory}. Skipping."
        return 1
    }

    # Bring down the Docker Compose stack
    log "Running docker compose down in ${directory}..."
    docker compose down || {
        log "Error running docker compose down in ${directory}"
        return 1
    }

    # Bring up the Docker Compose stack
    log "Running docker compose up -d in ${directory}..."
    docker compose up -d || {
        log "Error running docker compose up in ${directory}"
        return 1
    }

    log "Successfully refreshed Docker Compose in ${directory}"
    return 0
}

# Process each Docker Compose directory
refresh_docker_compose "$CONSOLE_CENTER"
refresh_docker_compose "$MEDIA_CENTER"

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
