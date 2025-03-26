#!/bin/bash

# Exit on error
set -e

# Script Description
# Rebuilds all Docker containers by pulling latest images and restarting services

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

# Function to process docker-compose for a given directory
process_docker_compose() {
    local dir="$1"
    log "Processing directory: $dir"

    if [ ! -d "$dir" ]; then
        log "Directory $dir does not exist. Skipping."
        return 1
    fi

    cd "$dir" || {
        log "Failed to change directory to $dir"
        return 1
    }

    log "Stopping containers in $dir"
    docker compose down || {
        log "Failed to stop containers in $dir"
        return 1
    }

    log "Pulling latest images in $dir"
    docker compose pull || {
        log "Failed to pull latest images in $dir"
        return 1
    }

    log "Starting containers in $dir"
    docker compose up -d || {
        log "Failed to start containers in $dir"
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

# Process each directory
process_docker_compose "$CONSOLE_CENTER"
process_docker_compose "$MEDIA_CENTER"

# Clean up any unused images, containers, networks, and volumes
prune_docker_system

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
