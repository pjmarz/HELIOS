#!/bin/bash

# Exit on error
set -e

# Script Description
# Restarts Docker service and all Docker Compose services in HELIOS system

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
        log "Error: Failed to start Docker service. Exiting."
        exit 1
    }
fi

# Restart Docker service
log "Restarting Docker service..."
sudo systemctl restart docker || {
    log "Error: Failed to restart Docker service. Exiting."
    exit 1
}

# Wait for Docker service to be fully operational
log "Waiting for Docker service to be fully operational..."
sleep 5

# Function to restart all services using the root docker-compose file
restart_all_services() {
    log "Navigating to ${HELIOS_ROOT}..."
    cd "$HELIOS_ROOT" || {
        log "Error: Failed to navigate to ${HELIOS_ROOT}. Exiting."
        exit 1
    }

    log "Cleaning up any stale container state..."
    docker compose down || {
        log "Warning: docker compose down failed, continuing anyway"
    }
    
    log "Starting all services with root docker-compose.yml in detached mode..."
    docker compose up -d || {
        log "Error: Failed to run docker compose up. Exiting."
        exit 1
    }

    log "Checking Docker Compose services status..."
    docker compose ps | tee -a "$LOG_FILE"
}

# Restart all services using the root docker-compose.yml
restart_all_services

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
