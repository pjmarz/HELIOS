#!/bin/bash

# Exit on error
set -e

# Script Description
# Stops all Docker Compose services in HELIOS system

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

# Function to run docker-compose down in a directory and log the output
run_docker_compose_down() {
    local directory="$1"
    log "Starting docker-compose down in ${directory}..."
    docker compose -f "${directory}/docker-compose.yml" down 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "docker-compose down finished successfully in ${directory}"
    else
        log "Error encountered while running docker-compose down in ${directory}"
    fi
}

# Run docker-compose down in all directories and log the output
run_docker_compose_down "$CONSOLE_CENTER" &
run_docker_compose_down "$MEDIA_CENTER" &

# Wait for all background processes to finish
wait

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
