#!/bin/bash

# Exit on error
set -e

# Script Description
# Starts all Docker Compose services in HELIOS system using the root docker-compose.yml

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

# Make sure Docker Compose specific .env file exists (copied from env.sh variables)
ENV_FILE_DOCKER="${HELIOS_ROOT}/.env"
if [ ! -f "$ENV_FILE_DOCKER" ]; then
    echo "Docker Compose .env file not found. Creating it from env.sh variables."
    # Create .env file for Docker Compose
    cat > "$ENV_FILE_DOCKER" <<EOL
# User/Group Settings
PUID=${PUID}
PGID=${PGID}
UMASK=${UMASK}

# Timezone
TZ=${TZ}

# Base Directories
LOAS=${LOAS}
MOVIES_DIR=${MOVIES_DIR}
TV_DIR=${TV_DIR}
DOWNLOADS_DIR=${DOWNLOADS_DIR}
CONFIG_DIR=${CONFIG_DIR}

# Console Services Ports
PORTAINER_PORT=${PORTAINER_PORT}
PORTAINER_SSL_PORT=${PORTAINER_SSL_PORT}
HOMARR_PORT=${HOMARR_PORT}
TAUTULLI_PORT=${TAUTULLI_PORT}
N8N_PORT=${N8N_PORT}
FLARESOLVERR_PORT=${FLARESOLVERR_PORT}

# Media Services Ports
OVERSEERR_PORT=${OVERSEERR_PORT}
RADARR_PORT=${RADARR_PORT}
SONARR_PORT=${SONARR_PORT}
BAZARR_PORT=${BAZARR_PORT}
PROWLARR_PORT=${PROWLARR_PORT}
SABNZBD_PORT=${SABNZBD_PORT}

# N8N Configuration
N8N_HOST=${N8N_HOST}
N8N_PROTOCOL=${N8N_PROTOCOL}
N8N_WEBHOOK_TUNNEL_URL=${N8N_WEBHOOK_TUNNEL_URL}

# Plex Configuration
PLEX_URL=${PLEX_URL}

# Logging
LOG_LEVEL=${LOG_LEVEL}

# Secret variables 
PLEX_TOKEN=${PLEX_TOKEN}
HOMARR_PASSWORD=${HOMARR_PASSWORD}
EOL
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

# Function to run docker-compose up with the root file
run_docker_compose_up() {
    log "Starting all services using root docker-compose.yml..."
    cd "$HELIOS_ROOT" || { log "Error: Could not change to $HELIOS_ROOT"; exit 1; }
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "All services started successfully"
    else
        log "Error encountered while starting services"
    fi
}

# Run docker-compose up using the root compose file
run_docker_compose_up

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT
