#!/bin/bash

# Exit on error
set -e

# Script Description
# Refreshes all Docker Compose services by stopping and starting them using the root docker-compose.yml

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

# Function to refresh Docker Compose services using the root compose file
refresh_docker_compose() {
    log "Starting refresh of all services..."

    cd "$HELIOS_ROOT" || {
        log "Failed to navigate to ${HELIOS_ROOT}. Exiting."
        return 1
    }

    # Bring down all services
    log "Running docker compose down..."
    docker compose down 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Error running docker compose down"
        return 1
    fi
    
    # Prune stopped containers
    log "Pruning stopped containers..."
    docker container prune -f 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Warning: Container pruning failed, continuing anyway"
    fi

    # Bring up all services
    log "Running docker compose up -d..."
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Error running docker compose up"
        return 1
    fi

    log "Successfully refreshed all Docker Compose services"
    return 0
}

# Refresh all services
refresh_docker_compose

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
