#!/bin/bash

# Exit on error
set -e

# Script Description
# Verifies the HELIOS system configuration, environment variables, and Docker setup

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

# Color output function that also logs to file without color codes
log_color() {
    local color="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${color}${timestamp} - ${msg}${NC}" 
    echo "${timestamp} - ${msg}" >> "$LOG_FILE"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_color "$RED" "Error on line $line_number: Exit code $exit_code"
    exit $exit_code
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log script start
log "=== Script Start ==="

log_color "$YELLOW" "Verifying HELIOS configuration..."

# Verify Docker is running
if command -v docker >/dev/null 2>&1; then
    log_color "$GREEN" "✓ Docker is installed"
else
    log_color "$RED" "✗ Docker is not installed"
    exit 1
fi

# Verify Docker Compose is available
if docker compose version >/dev/null 2>&1; then
    log_color "$GREEN" "✓ Docker Compose is available"
else
    log_color "$RED" "✗ Docker Compose is not available"
    exit 1
fi

# Verify Docker Compose configuration
log_color "$YELLOW" "Validating Docker Compose files..."
if docker compose -f "${HELIOS_ROOT}/docker-compose.yml" config >/dev/null 2>&1; then
    log_color "$GREEN" "✓ Docker Compose configuration is valid"
else
    log_color "$RED" "✗ Docker Compose configuration is invalid"
    docker compose -f "${HELIOS_ROOT}/docker-compose.yml" config 2>&1 | tee -a "$LOG_FILE"
    exit 1
fi

# Verify environment variables
log_color "$YELLOW" "Checking required environment variables..."
MISSING_VARS=0

check_var() {
    if [ -z "${!1}" ]; then
        log_color "$RED" "✗ Missing environment variable: $1"
        MISSING_VARS=$((MISSING_VARS+1))
    else
        local value="${!1}"
        # Mask sensitive values in logs
        if [[ "$1" == *"TOKEN"* || "$1" == *"PASSWORD"* || "$1" == *"SECRET"* ]]; then
            value="********"
        fi
        log_color "$GREEN" "✓ $1 = $value"
    fi
}

# Check base config
check_var "PUID"
check_var "PGID"
check_var "TZ"
check_var "UMASK"

# Check directories
check_var "CONFIG_DIR"
check_var "MOVIES_DIR"
check_var "TV_DIR"
check_var "DOWNLOADS_DIR"

# Check ports
check_var "PORTAINER_PORT"
check_var "PORTAINER_SSL_PORT"
check_var "HOMARR_PORT"
check_var "TAUTULLI_PORT"
check_var "N8N_PORT"
check_var "FLARESOLVERR_PORT"
check_var "OVERSEERR_PORT"
check_var "RADARR_PORT"
check_var "SONARR_PORT"
check_var "BAZARR_PORT"
check_var "PROWLARR_PORT"
check_var "SABNZBD_PORT"

# Check logging
check_var "LOG_LEVEL"

# Check N8N config
check_var "N8N_HOST"
check_var "N8N_PROTOCOL"
check_var "N8N_WEBHOOK_TUNNEL_URL"

# Check Plex config
check_var "PLEX_URL"

# Check for log file naming convention update
log_color "$YELLOW" "Checking log files naming convention..."
if [ -d "$LOG_DIR" ]; then
    LEGACY_LOGS=$(find "$LOG_DIR" -name "master-compose-*.log" -o -name "restart-docker.log" -o -name "clean-usenet.log" -o -name "verify-config.log" | wc -l)
    NEW_LOGS=$(find "$LOG_DIR" -name "compose-*.log" -o -name "docker-*.log" -o -name "media-*.log" -o -name "system-*.log" | wc -l)
    
    if [ $LEGACY_LOGS -gt 0 ] && [ $NEW_LOGS -gt 0 ]; then
        log_color "$YELLOW" "⚠ Both legacy and new log naming conventions found"
        log_color "$YELLOW" "  Consider removing legacy log files after confirming new scripts work correctly"
    elif [ $LEGACY_LOGS -gt 0 ] && [ $NEW_LOGS -eq 0 ]; then
        log_color "$YELLOW" "⚠ Only legacy log files found - new scripts haven't been run yet"
    elif [ $NEW_LOGS -gt 0 ]; then
        log_color "$GREEN" "✓ Using new log naming convention"
    fi
else
    log_color "$YELLOW" "⚠ Logs directory not found"
fi

# Check secret variables
log_color "$YELLOW" "Checking secret variables..."
if [ -z "$PLEX_TOKEN" ]; then
    log_color "$RED" "✗ Missing secret: PLEX_TOKEN"
    MISSING_VARS=$((MISSING_VARS+1))
else
    log_color "$GREEN" "✓ PLEX_TOKEN is set"
fi

if [ -z "$HOMARR_PASSWORD" ]; then
    log_color "$RED" "✗ Missing secret: HOMARR_PASSWORD"
    MISSING_VARS=$((MISSING_VARS+1))
else
    log_color "$GREEN" "✓ HOMARR_PASSWORD is set"
fi

# Final report
log_color "$YELLOW" "Verification complete"
if [ $MISSING_VARS -gt 0 ]; then
    log_color "$RED" "✗ Found $MISSING_VARS missing variables"
    exit 1
else
    log_color "$GREEN" "✓ All configuration variables are present"
    log_color "$GREEN" "✓ HELIOS configuration is valid"
    log_color "$GREEN" "You can start HELIOS by running: docker compose up -d"
fi

# Cleanup function
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT 