#!/bin/bash

# Exit on error
set -e

# Script Description
# Rebuilds all Docker containers by pulling latest images and restarting services using the root docker-compose.yml

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

# Function to rebuild all docker services using the root compose file
rebuild_docker_services() {
    log "Rebuilding all services using root docker-compose.yml"

    cd "$HELIOS_ROOT" || {
        log "Failed to change directory to $HELIOS_ROOT"
        return 1
    }

    log "Stopping all containers"
    docker compose down || {
        log "Failed to stop containers"
        return 1
    }

    log "Pulling latest images for all services"
    docker compose pull || {
        log "Failed to pull latest images"
        return 1
    }

    log "Starting all containers"
    docker compose up -d || {
        log "Failed to start containers"
        return 1
    }

    return 0
}

# Function to prune unused docker resources
prune_docker_system() {
    log "Pruning unused Docker resources"
    docker system prune -af || {
        log "Failed to prune Docker system"
        return 1
    }
}

# Rebuild all services
rebuild_docker_services

# Clean up any unused images, containers, networks, and volumes
prune_docker_system

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
