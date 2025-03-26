#!/bin/bash

# Exit on error
set -e

# Script Description
# Restarts Docker service and all Docker Compose services in HELIOS system

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

# Check Docker service status
log "Checking Docker service status..."
if systemctl is-active --quiet docker; then
    log "Docker is active."
else
    log "Docker is not active. Attempting to start..."
    sudo systemctl start docker || {
        log "Error starting Docker service. Exiting."
        exit 1
    }
fi

# Restart Docker service
log "Restarting Docker service..."
sudo systemctl restart docker || {
    log "Error restarting Docker service. Exiting."
    exit 1
}

# Function to restart docker-compose in a specific directory
restart_docker_compose() {
    local directory="$1"
    log "Navigating to ${directory}..."
    cd "$directory" || {
        log "Error navigating to ${directory}. Exiting."
        exit 1
    }

    log "Running docker compose up in detached mode..."
    docker compose up -d || {
        log "Error running docker compose up in ${directory}. Exiting."
        exit 1
    }

    log "Checking Docker Compose services status in ${directory}..."
    docker compose ps | tee -a "$LOG_FILE"
}

# Restart docker-compose for Console Command Center
restart_docker_compose "$CONSOLE_CENTER"

# Restart docker-compose for Media Management Center
restart_docker_compose "$MEDIA_CENTER"

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
