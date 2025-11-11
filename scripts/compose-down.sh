#!/bin/bash

# Exit on error
set -e

# Script Description
# Stops all Docker Compose services in HELIOS system using the root docker-compose.yml

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

# Function to run docker-compose down with the root file
run_docker_compose_down() {
    log "Stopping all services using root docker-compose.yml..."
    cd "$HELIOS_ROOT" || { log "Error: Could not change to $HELIOS_ROOT"; exit 1; }
    
    # Run docker compose down and capture output, preserving exit code
    docker compose down 2>&1 | tee -a "$LOG_FILE"
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -eq 0 ]; then
        log "All services stopped successfully"
    else
        log "Error encountered while stopping services (exit code: $exit_code)"
        exit $exit_code
    fi
    
    # Prune stopped containers (non-critical, so don't fail on error)
    log "Pruning stopped containers..."
    if docker container prune -f 2>&1 | tee -a "$LOG_FILE"; then
        log "Container pruning completed successfully"
    else
        log "Warning: Container pruning failed (non-critical)"
    fi
}

# Run docker-compose down using the root compose file
run_docker_compose_down

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
