#!/bin/bash
# ===========================================================================
# HELIOS SYSTEM VERIFY SCRIPT
# ===========================================================================
# Verifies the HELIOS system configuration, environment variables, and
# Docker setup.
# ===========================================================================

# Exit on error
set -e

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

# Verify config directory exists and is accessible
log_color "$YELLOW" "Checking config directory..."
if [ -d "$CONFIG_DIR" ]; then
    log_color "$GREEN" "✓ Config directory exists at $CONFIG_DIR"
    # Check if it's writable
    if [ -w "$CONFIG_DIR" ]; then
        log_color "$GREEN" "✓ Config directory is writable"
    else
        log_color "$RED" "✗ Config directory is not writable"
        log_color "$YELLOW" "  Try: sudo chmod -R 755 $CONFIG_DIR"
        log_color "$YELLOW" "  And: sudo chown -R $PUID:$PGID $CONFIG_DIR"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
else
    log_color "$RED" "✗ Config directory does not exist at $CONFIG_DIR"
    log_color "$YELLOW" "  Creating directory..."
    mkdir -p "$CONFIG_DIR" && \
    log_color "$GREEN" "✓ Created config directory at $CONFIG_DIR" || \
    (log_color "$RED" "✗ Failed to create config directory" && MISSING_VARS=$((MISSING_VARS+1)))
fi

# Check ports
check_var "PORTAINER_PORT"
check_var "PORTAINER_SSL_PORT"
check_var "HOMARR_PORT"
check_var "TAUTULLI_PORT"
check_var "FLARESOLVERR_PORT"
check_var "OVERSEERR_PORT"
check_var "RADARR_PORT"
check_var "SONARR_PORT"
check_var "BAZARR_PORT"
check_var "PROWLARR_PORT"
check_var "SABNZBD_PORT"

# Check logging
check_var "LOG_LEVEL"

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

# Check for Docker Secrets
HELIOS_SECRETS_DIR="${HELIOS_ROOT}/secrets"
HOMARR_KEY_VALUE=""
if [ -d "$HELIOS_SECRETS_DIR" ]; then
    log_color "$GREEN" "✓ Docker Secrets directory exists at $HELIOS_SECRETS_DIR"
    
    # Check for Plex token
    if [ -f "${HELIOS_SECRETS_DIR}/plex_token.txt" ]; then
        # Verify file has content
        if [ -s "${HELIOS_SECRETS_DIR}/plex_token.txt" ]; then
            log_color "$GREEN" "✓ Plex token secret file exists and has content"
        else
            log_color "$RED" "✗ Plex token secret file exists but is empty"
            MISSING_VARS=$((MISSING_VARS+1))
        fi
    else
        log_color "$RED" "✗ Missing secret file: plex_token.txt"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
    
    # Check for Homarr encryption key
    if [ -f "${HELIOS_SECRETS_DIR}/homarr_encryption_key.txt" ]; then
        # Verify file has content
        if [ -s "${HELIOS_SECRETS_DIR}/homarr_encryption_key.txt" ]; then
            log_color "$GREEN" "✓ Homarr encryption key secret file exists and has content"
            HOMARR_KEY_VALUE=$(tr -d '\n' < "${HELIOS_SECRETS_DIR}/homarr_encryption_key.txt" | tr -d '\r')
        else
            log_color "$RED" "✗ Homarr encryption key secret file exists but is empty"
            MISSING_VARS=$((MISSING_VARS+1))
        fi
    elif [ -n "$HOMARR_ENCRYPTION_KEY" ]; then
        log_color "$GREEN" "✓ HOMARR_ENCRYPTION_KEY provided via environment"
        HOMARR_KEY_VALUE="$HOMARR_ENCRYPTION_KEY"
    else
        log_color "$RED" "✗ Missing Homarr encryption key (provide secrets/homarr_encryption_key.txt or HOMARR_ENCRYPTION_KEY env var)"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
    
    # Check file permissions
    INSECURE_PERMS=0
    for SECRET_FILE in "${HELIOS_SECRETS_DIR}"/*.txt; do
        if [ -f "$SECRET_FILE" ]; then
            FILE_PERMS=$(stat -c "%a" "$SECRET_FILE")
            if [[ "$FILE_PERMS" != "600" ]]; then
                log_color "$RED" "✗ Insecure permissions ($FILE_PERMS) on $(basename "$SECRET_FILE")"
                log_color "$YELLOW" "  Try: chmod 600 $SECRET_FILE"
                INSECURE_PERMS=$((INSECURE_PERMS+1))
            fi
        fi
    done
    
    if [ $INSECURE_PERMS -eq 0 ]; then
        log_color "$GREEN" "✓ All secret files have secure permissions"
    else
        MISSING_VARS=$((MISSING_VARS+$INSECURE_PERMS))
    fi
else
    log_color "$RED" "✗ Docker Secrets directory not found at $HELIOS_SECRETS_DIR"
    log_color "$YELLOW" "  HELIOS now uses Docker Secrets for sensitive information"
    log_color "$YELLOW" "  Try: mkdir -p $HELIOS_SECRETS_DIR"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Generate or update local .env for docker compose (not committed)
DOTENV_FILE="${HELIOS_ROOT}/.env"
if [ -n "$HOMARR_KEY_VALUE" ]; then
  # Ensure file exists
  if [ ! -f "$DOTENV_FILE" ]; then
    printf "# Generated by system-verify.sh on %s\n" "$(date -Is)" > "$DOTENV_FILE"
  fi
  # Remove existing key line (if any) and append fresh value
  sed -i '/^HOMARR_ENCRYPTION_KEY=/d' "$DOTENV_FILE" 2>/dev/null || true
  echo "HOMARR_ENCRYPTION_KEY=$HOMARR_KEY_VALUE" >> "$DOTENV_FILE"
  log_color "$GREEN" "✓ Wrote HOMARR_ENCRYPTION_KEY to .env for docker compose"
fi

# ======== NEW ADDITIONS START HERE ========

# Check media directory permissions
log_color "$YELLOW" "Checking media directory permissions..."

check_media_dir() {
    local dir="$1"
    local name="$2"
    
    if [ -d "$dir" ]; then
        log_color "$GREEN" "✓ $name directory exists at $dir"
        
        if [ -r "$dir" ]; then
            log_color "$GREEN" "✓ $name directory is readable"
        else
            log_color "$RED" "✗ $name directory is not readable"
            log_color "$YELLOW" "  Try: sudo chmod -R 755 $dir"
            MISSING_VARS=$((MISSING_VARS+1))
        fi
        
        if [ -w "$dir" ]; then
            log_color "$GREEN" "✓ $name directory is writable"
        else
            log_color "$RED" "✗ $name directory is not writable"
            log_color "$YELLOW" "  Try: sudo chown -R $PUID:$PGID $dir"
            MISSING_VARS=$((MISSING_VARS+1))
        fi
    else
        log_color "$RED" "✗ $name directory does not exist at $dir"
        log_color "$YELLOW" "  Creating directory..."
        mkdir -p "$dir" && \
        log_color "$GREEN" "✓ Created $name directory at $dir" || \
        (log_color "$RED" "✗ Failed to create $name directory" && MISSING_VARS=$((MISSING_VARS+1)))
    fi
}

check_media_dir "$MOVIES_DIR" "Movies"
check_media_dir "$TV_DIR" "TV Shows"
check_media_dir "$DOWNLOADS_DIR" "Downloads"
check_media_dir "$DOWNLOADS_DIR/complete" "Downloads complete"
check_media_dir "$DOWNLOADS_DIR/incomplete" "Downloads incomplete"

# Check for NVIDIA GPU support
log_color "$YELLOW" "Checking NVIDIA GPU support..."
if command -v nvidia-smi &>/dev/null; then
    nvidia_smi_output=$(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader)
    if [ $? -eq 0 ]; then
        log_color "$GREEN" "✓ NVIDIA GPU detected: $nvidia_smi_output"
    else
        log_color "$RED" "✗ NVIDIA GPU detection failed, check driver installation"
        log_color "$YELLOW" "  This may affect GPU-accelerated applications"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
else
    log_color "$RED" "✗ nvidia-smi not found, NVIDIA driver not installed"
    log_color "$YELLOW" "  GPU acceleration may not work properly"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check for NVIDIA Docker runtime
log_color "$YELLOW" "Checking NVIDIA Docker runtime..."
if docker info | grep -q "Runtimes:.*nvidia"; then
    log_color "$GREEN" "✓ NVIDIA Docker runtime is available"
else
    log_color "$RED" "✗ NVIDIA Docker runtime is not configured"
    log_color "$YELLOW" "  GPU acceleration for containers won't work"
    log_color "$YELLOW" "  See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Network connectivity check
log_color "$YELLOW" "Checking network connectivity..."

# Verify Plex server connectivity (Docker container)
if curl --connect-timeout 5 --silent --head "$PLEX_URL" >/dev/null; then
    log_color "$GREEN" "✓ Plex server is reachable at $PLEX_URL"
else
    log_color "$RED" "✗ Cannot reach Plex server at $PLEX_URL"
    log_color "$YELLOW" "  Ensure the Plex container is running and accessible"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check internet connectivity
if ping -c 1 google.com >/dev/null 2>&1; then
    log_color "$GREEN" "✓ Internet connection is available"
else
    log_color "$RED" "✗ No internet connection detected"
    log_color "$YELLOW" "  Download-oriented services may not work properly"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Docker and Docker Compose version checks
log_color "$YELLOW" "Checking Docker and Docker Compose versions..."

# Check Docker version
DOCKER_VERSION=$(docker --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
if [ -n "$DOCKER_VERSION" ]; then
    DOCKER_MAJOR=$(echo "$DOCKER_VERSION" | cut -d. -f1)
    DOCKER_MINOR=$(echo "$DOCKER_VERSION" | cut -d. -f2)
    
    # Version is adequate if major > 20, or major == 20 and minor >= 10
    if [ "$DOCKER_MAJOR" -gt 20 ] || ([ "$DOCKER_MAJOR" -eq 20 ] && [ "$DOCKER_MINOR" -ge 10 ]); then
        log_color "$GREEN" "✓ Docker version $DOCKER_VERSION is adequate"
    else
        log_color "$YELLOW" "⚠ Docker version $DOCKER_VERSION is older than recommended (20.10+)"
        log_color "$YELLOW" "  Consider upgrading for better security and features"
    fi
else
    log_color "$RED" "✗ Could not determine Docker version"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check Docker Compose version
COMPOSE_VERSION=$(docker compose version --short 2>/dev/null)
if [ -n "$COMPOSE_VERSION" ]; then
    COMPOSE_VERSION_MAJOR=$(echo "$COMPOSE_VERSION" | cut -d. -f1)
    COMPOSE_VERSION_MINOR=$(echo "$COMPOSE_VERSION" | cut -d. -f2)
    
    if [ "$COMPOSE_VERSION_MAJOR" -ge 2 ] || ([ "$COMPOSE_VERSION_MAJOR" -eq 1 ] && [ "$COMPOSE_VERSION_MINOR" -ge 28 ]); then
        log_color "$GREEN" "✓ Docker Compose version $COMPOSE_VERSION is adequate"
    else
        log_color "$RED" "✗ Docker Compose version $COMPOSE_VERSION may be too old"
        log_color "$YELLOW" "  Version 1.28.0 or higher is recommended for include feature support"
        log_color "$YELLOW" "  Update with: sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
else
    log_color "$RED" "✗ Could not determine Docker Compose version"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check available system memory
log_color "$YELLOW" "Checking system memory..."
TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
AVAIL_MEM_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
AVAIL_MEM_GB=$((AVAIL_MEM_KB / 1024 / 1024))

if [ "$TOTAL_MEM_GB" -ge 8 ]; then
    log_color "$GREEN" "✓ System has adequate memory (${TOTAL_MEM_GB}GB total, ${AVAIL_MEM_GB}GB available)"
else
    log_color "$YELLOW" "⚠ System has limited memory (${TOTAL_MEM_GB}GB total, ${AVAIL_MEM_GB}GB available)"
    log_color "$YELLOW" "  HELIOS services may perform better with 8GB+ RAM"
fi

# Check if swap is configured
SWAP_TOTAL=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
if [ "$SWAP_TOTAL" -gt 0 ]; then
    SWAP_GB=$((SWAP_TOTAL / 1024 / 1024))
    log_color "$GREEN" "✓ Swap is configured (${SWAP_GB}GB)"
else
    log_color "$YELLOW" "⚠ No swap configured"
    log_color "$YELLOW" "  Consider adding swap for better system stability under memory pressure"
fi

# Docker Volume verification
log_color "$YELLOW" "Checking Docker volumes..."

# List of expected volume names from docker-compose.yml
EXPECTED_VOLUMES=("helios_portainer_data" "helios_homarr_data")

for vol in "${EXPECTED_VOLUMES[@]}"; do
    if docker volume inspect "$vol" >/dev/null 2>&1; then
        log_color "$GREEN" "✓ Docker volume $vol exists"
    else
        log_color "$YELLOW" "⚠ Docker volume $vol doesn't exist yet (will be created on first run)"
    fi
done

# Deployment files verification
log_color "$YELLOW" "Checking deployment files..."

# Check for console deployment
if [ -f "${HELIOS_ROOT}/deployments/console/docker-compose.yml" ]; then
    log_color "$GREEN" "✓ Console services compose file exists"
else
    log_color "$RED" "✗ Console services compose file missing"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check for media deployment
if [ -f "${HELIOS_ROOT}/deployments/media/docker-compose.yml" ]; then
    log_color "$GREEN" "✓ Media services compose file exists"
else
    log_color "$RED" "✗ Media services compose file missing"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Disk space verification
log_color "$YELLOW" "Checking disk space..."

# Check main media storage
LOAS_DISK_USAGE=$(df -h "$LOAS" | awk 'NR==2 {print $5}' | tr -d '%')
LOAS_AVAILABLE=$(df -h "$LOAS" | awk 'NR==2 {print $4}')

if [ "$LOAS_DISK_USAGE" -lt 90 ]; then
    log_color "$GREEN" "✓ Media storage at $LOAS has adequate space ($LOAS_AVAILABLE available)"
else
    log_color "$RED" "✗ Media storage at $LOAS is nearly full (${LOAS_DISK_USAGE}% used, only $LOAS_AVAILABLE available)"
    log_color "$YELLOW" "  Services may fail if disk space runs out"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check config directory
CONFIG_DISK_USAGE=$(df -h "$CONFIG_DIR" | awk 'NR==2 {print $5}' | tr -d '%')
CONFIG_AVAILABLE=$(df -h "$CONFIG_DIR" | awk 'NR==2 {print $4}')

if [ "$CONFIG_DISK_USAGE" -lt 90 ]; then
    log_color "$GREEN" "✓ Config storage at $CONFIG_DIR has adequate space ($CONFIG_AVAILABLE available)"
else
    log_color "$RED" "✗ Config storage at $CONFIG_DIR is nearly full (${CONFIG_DISK_USAGE}% used, only $CONFIG_AVAILABLE available)"
    log_color "$YELLOW" "  Services may fail if disk space runs out"
    MISSING_VARS=$((MISSING_VARS+1))
fi

# Check .env and env.sh consistency
log_color "$YELLOW" "Checking environment file consistency..."

# Extract variables from env.sh (excluding export statements)
ENV_SH_VARS=$(grep -v "^#" "${HELIOS_ROOT}/env.sh" | grep "export" | sed 's/export //g' | sed 's/=.*//g')

# Extract variables from .env
ENV_FILE_VARS=$(grep -v "^#" "${HELIOS_ROOT}/.env" | grep -v "^$" | sed 's/=.*//g')

# Compare variables
for var in $ENV_SH_VARS; do
    if echo "$ENV_FILE_VARS" | grep -q "$var"; then
        log_color "$GREEN" "✓ Variable $var exists in both env.sh and .env"
    else
        log_color "$RED" "✗ Variable $var exists in env.sh but is missing from .env"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
done

# Service Health Checks
log_color "$YELLOW" "Checking service health (if running)..."

# Function to check if a service is healthy
check_service_health() {
    local service_name="$1"
    local expected_port="$2"
    
    if docker ps --format '{{.Names}}' | grep -w "$service_name" >/dev/null; then
        log_color "$GREEN" "✓ $service_name container is running"
        
        # Check if service responds on expected port
        if curl --connect-timeout 5 --silent --head "http://localhost:$expected_port" >/dev/null 2>&1; then
            log_color "$GREEN" "✓ $service_name is responding on port $expected_port"
        else
            log_color "$YELLOW" "⚠ $service_name container running but not responding on port $expected_port"
        fi
    else
        log_color "$YELLOW" "⚠ $service_name container is not running (this is normal if services haven't been started)"
    fi
}

# Check key services if they're running
check_service_health "portainer" "$PORTAINER_PORT"
check_service_health "homarr" "$HOMARR_PORT"
check_service_health "tautulli" "$TAUTULLI_PORT"
check_service_health "overseerr" "$OVERSEERR_PORT"
check_service_health "radarr" "$RADARR_PORT"
check_service_health "sonarr" "$SONARR_PORT"
check_service_health "sabnzbd" "$SABNZBD_PORT"

# Container Resource Usage Check
log_color "$YELLOW" "Checking Docker system resource usage..."
if command -v docker >/dev/null 2>&1 && docker ps >/dev/null 2>&1; then
    DOCKER_STATS=$(docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" 2>/dev/null || echo "")
    if [ -n "$DOCKER_STATS" ]; then
        log_color "$GREEN" "✓ Docker system resource usage obtained"
        echo "$DOCKER_STATS" | tee -a "$LOG_FILE"
    else
        log_color "$YELLOW" "⚠ Could not get Docker system resource usage"
    fi
else
    log_color "$YELLOW" "⚠ Docker not accessible for resource usage check"
fi

# Security and Configuration Best Practices
log_color "$YELLOW" "Checking security and configuration best practices..."

# Check for Docker socket exposure in compose files
log_color "$YELLOW" "Checking for Docker socket exposure..."
DOCKER_SOCKET_MOUNTS=$(grep -r "/var/run/docker.sock" "${HELIOS_ROOT}/deployments/" "${HELIOS_ROOT}/docker-compose.yml" 2>/dev/null | wc -l)
if [ "$DOCKER_SOCKET_MOUNTS" -gt 0 ]; then
    log_color "$YELLOW" "⚠ Docker socket is mounted in $DOCKER_SOCKET_MOUNTS service(s)"
    log_color "$YELLOW" "  This provides elevated privileges - ensure services are from trusted sources"
    
    # List which services expose the socket
    grep -r "/var/run/docker.sock" "${HELIOS_ROOT}/deployments/" "${HELIOS_ROOT}/docker-compose.yml" 2>/dev/null | while read -r line; do
        service_file=$(echo "$line" | cut -d: -f1)
        log_color "$YELLOW" "  Found in: $(basename "$service_file")"
    done
else
    log_color "$GREEN" "✓ No Docker socket exposure detected"
fi

# Check for privileged containers
log_color "$YELLOW" "Checking for privileged containers..."
PRIVILEGED_CONTAINERS=$(grep -r "privileged.*true" "${HELIOS_ROOT}/deployments/" "${HELIOS_ROOT}/docker-compose.yml" 2>/dev/null | wc -l)
if [ "$PRIVILEGED_CONTAINERS" -gt 0 ]; then
    log_color "$YELLOW" "⚠ Found $PRIVILEGED_CONTAINERS privileged container(s)"
    log_color "$YELLOW" "  Privileged containers have elevated security risks"
else
    log_color "$GREEN" "✓ No privileged containers detected"
fi

# Check for host network mode
log_color "$YELLOW" "Checking for host network mode usage..."
HOST_NETWORK_USAGE=$(grep -r "network_mode.*host" "${HELIOS_ROOT}/deployments/" "${HELIOS_ROOT}/docker-compose.yml" 2>/dev/null | wc -l)
if [ "$HOST_NETWORK_USAGE" -gt 0 ]; then
    log_color "$YELLOW" "⚠ Found $HOST_NETWORK_USAGE service(s) using host network mode"
    log_color "$YELLOW" "  Host network mode reduces container isolation"
else
    log_color "$GREEN" "✓ No host network mode usage detected"
fi

# Check for plaintext sensitive data in compose files
log_color "$YELLOW" "Checking for potential plaintext sensitive data..."
POTENTIAL_SECRETS=$(grep -ri "password\|token\|secret\|key" "${HELIOS_ROOT}/deployments/" "${HELIOS_ROOT}/docker-compose.yml" 2>/dev/null | grep -v "secrets:" | grep -v "_FILE" | wc -l)
if [ "$POTENTIAL_SECRETS" -gt 5 ]; then  # Allow some normal configuration references
    log_color "$YELLOW" "⚠ Found $POTENTIAL_SECRETS potential sensitive data references"
    log_color "$YELLOW" "  Review compose files to ensure secrets use Docker Secrets or _FILE variables"
else
    log_color "$GREEN" "✓ No obvious plaintext sensitive data detected"
fi

# Check for missing restart policies
log_color "$YELLOW" "Checking service restart policies..."
NO_RESTART_SERVICES=$(grep -A 20 "services:" "${HELIOS_ROOT}/deployments/"*/docker-compose.yml 2>/dev/null | grep -B 15 -A 5 "image:" | grep -B 10 -A 10 "container_name" | grep -L "restart:" | wc -l)
if [ "$NO_RESTART_SERVICES" -gt 0 ]; then
    log_color "$YELLOW" "⚠ Some services may not have restart policies defined"
    log_color "$YELLOW" "  Services without restart policies won't auto-recover from failures"
else
    log_color "$GREEN" "✓ Restart policies appear to be configured"
fi

# Check for external network dependencies
log_color "$YELLOW" "Checking external network dependencies..."
REQUIRED_NETWORKS=("helios_proxy" "helios_console_agent_network" "helios_default")
for network in "${REQUIRED_NETWORKS[@]}"; do
    if docker network ls | grep -q "$network"; then
        log_color "$GREEN" "✓ Required external network '$network' exists"
    else
        log_color "$RED" "✗ Required external network '$network' does not exist"
        log_color "$YELLOW" "  Create with: docker network create $network"
        MISSING_VARS=$((MISSING_VARS+1))
    fi
done

# ======== NEW ADDITIONS END HERE ========

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