#!/bin/bash
# ===========================================================================
# HELIOS API CONNECTIVITY TEST
# ===========================================================================
# Tests API connectivity to all HELIOS services using secrets from ./secrets/
# ===========================================================================

# Don't exit on error - we want to test all services
set +e

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

# Initialize log file (overwrite previous output)
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

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Secrets directory
SECRETS_DIR="${HELIOS_ROOT}/secrets"

# Service host (assuming localhost)
HOST="localhost"

# Log script start
log "=== Script Start ==="

log_color "$YELLOW" "╔════════════════════════════════════════════════════════════════╗"
log_color "$YELLOW" "║     🔍 HELIOS API CONNECTIVITY TEST                         ║"
log_color "$YELLOW" "╚════════════════════════════════════════════════════════════════╝"
log ""

# Function to test API endpoint
test_api() {
    local service_name=$1
    local api_key_file=$2
    local base_url=$3
    local api_path=$4
    local api_key_param=$5
    
    # Read API key
    if [ ! -f "${SECRETS_DIR}/${api_key_file}" ]; then
        log_color "$RED" "✗ ${service_name}: Missing API key file"
        return 1
    fi
    
    local api_key=$(cat "${SECRETS_DIR}/${api_key_file}" | tr -d '\n\r ')
    
    if [ -z "$api_key" ]; then
        log_color "$RED" "✗ ${service_name}: Empty API key"
        return 1
    fi
    
    # Build URL
    local url="${base_url}${api_path}"
    if [ -n "$api_key_param" ]; then
        url="${url}${api_key_param}${api_key}"
    fi
    
    # Test connection
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null || echo "000")
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        log_color "$GREEN" "✓ ${service_name}: Connected (HTTP ${http_code})"
        return 0
    else
        log_color "$RED" "✗ ${service_name}: Failed (HTTP ${http_code})"
        return 1
    fi
}

# Function to test API endpoint with header authentication
test_api_header() {
    local service_name=$1
    local api_key_file=$2
    local base_url=$3
    local api_path=$4
    local header_name=$5
    
    # Read API key
    if [ ! -f "${SECRETS_DIR}/${api_key_file}" ]; then
        log_color "$RED" "✗ ${service_name}: Missing API key file"
        return 1
    fi
    
    local api_key=$(cat "${SECRETS_DIR}/${api_key_file}" | tr -d '\n\r ')
    
    if [ -z "$api_key" ]; then
        log_color "$RED" "✗ ${service_name}: Empty API key"
        return 1
    fi
    
    # Build URL
    local url="${base_url}${api_path}"
    
    # Determine if HTTPS (for self-signed certificates, use -k flag)
    local curl_opts=""
    if [[ "$base_url" == https://* ]]; then
        curl_opts="-k"  # Skip SSL certificate verification for self-signed certs
    fi
    
    # Test connection with header
    local http_code=$(curl -s $curl_opts -o /dev/null -w "%{http_code}" -H "${header_name}: ${api_key}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null || echo "000")
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        log_color "$GREEN" "✓ ${service_name}: Connected (HTTP ${http_code})"
        return 0
    else
        log_color "$RED" "✗ ${service_name}: Failed (HTTP ${http_code})"
        return 1
    fi
}

# Test each service
PASSED=0
FAILED=0

log ""
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_color "$YELLOW" "MEDIA SERVICES:"
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Radarr
if test_api "Radarr" "radarr_api_key.txt" "http://${HOST}:${RADARR_PORT:-7878}" "/api/v3/system/status" "?apikey="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Sonarr
if test_api "Sonarr" "sonarr_api_key.txt" "http://${HOST}:${SONARR_PORT:-8989}" "/api/v3/system/status" "?apikey="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Bazarr
if test_api "Bazarr" "bazarr_api_key.txt" "http://${HOST}:${BAZARR_PORT:-6767}" "/api/system/status" "?apikey="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Prowlarr
if test_api "Prowlarr" "prowlarr_api_key.txt" "http://${HOST}:${PROWLARR_PORT:-9696}" "/api/v1/system/status" "?apikey="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# SABnzbd
if test_api "SABnzbd" "sabnzbd_api_key.txt" "http://${HOST}:${SABNZBD_PORT:-8080}" "/api?mode=version" "&apikey="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Overseerr
if test_api "Overseerr" "overseerr_api_key.txt" "http://${HOST}:${OVERSEERR_PORT:-5055}" "/api/v1/status" ""; then
    ((PASSED++))
else
    ((FAILED++))
fi

log ""
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_color "$YELLOW" "CONSOLE SERVICES:"
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Tautulli
if test_api "Tautulli" "tautulli_api_key.txt" "http://${HOST}:${TAUTULLI_PORT:-8181}" "/api/v2?cmd=get_server_info" "&apikey="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Homarr
if test_api_header "Homarr" "homarr_api_key.txt" "http://${HOST}:${HOMARR_PORT:-7575}" "/api/users/selectable" "ApiKey"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Portainer
if test_api_header "Portainer" "portainer_api_token.txt" "https://${HOST}:${PORTAINER_SSL_PORT:-9443}" "/api/stacks" "X-API-Key"; then
    ((PASSED++))
else
    ((FAILED++))
fi

log ""
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_color "$YELLOW" "MEDIA SERVER:"
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Plex (Docker container)
if test_api "Plex" "plex_token.txt" "${PLEX_URL:-http://localhost:32400}" "/status/sessions" "?X-Plex-Token="; then
    ((PASSED++))
else
    ((FAILED++))
fi

# Summary
log ""
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_color "$GREEN" "✓ Passed: ${PASSED}"
if [ $FAILED -gt 0 ]; then
    log_color "$RED" "✗ Failed: ${FAILED}"
fi
log_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup function
cleanup() {
    local final_exit_code=0
    if [ $FAILED -gt 0 ]; then
        final_exit_code=1
    fi
    log "=== Script Complete (Exit Code: $final_exit_code) ==="
    exit $final_exit_code
}

trap cleanup EXIT

