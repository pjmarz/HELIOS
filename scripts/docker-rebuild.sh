#!/bin/bash
# ===========================================================================
# HELIOS DOCKER REBUILD SCRIPT
# ===========================================================================
# Rebuilds all Docker containers by pulling latest images and restarting
# services. Includes cleanup of unused Docker resources.
# ===========================================================================

HELIOS_START_MSG="HELIOS Docker Rebuild Script Start"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

log "Project root: $HELIOS_ROOT"

# Function to ensure required external networks exist
ensure_external_networks() {
    log "Ensuring required external networks exist..."

    local networks=("helios_proxy" "helios_console_agent_network")

    for net in "${networks[@]}"; do
        if ! docker network inspect "$net" &>/dev/null; then
            log "Creating missing network: $net"
            docker network create "$net" 2>&1 | tee -a "$LOG_FILE"
        else
            log "Network already exists: $net"
        fi
    done

    log "External networks check complete"
    return 0
}

# Function to rebuild all docker services using the root compose file
rebuild_docker_services() {
    log "Rebuilding all services using docker-compose.yml"

    cd "$HELIOS_ROOT" || {
        log "Failed to change directory to $HELIOS_ROOT"
        return 1
    }

    log "Stopping all containers..."
    docker compose down 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Failed to stop containers"
        return 1
    fi

    log "Pulling latest images for all services..."
    docker compose pull 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Failed to pull latest images"
        return 1
    fi

    log "Starting all containers..."
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Failed to start containers"
        return 1
    fi

    log "Waiting for services to be healthy..."
    sleep 5

    # Show container status
    log "Container status:"
    docker compose ps 2>&1 | tee -a "$LOG_FILE"

    return 0
}

# Function to prune unused docker resources
prune_docker_system() {
    log "Pruning unused Docker resources..."

    log "Pruning stopped containers..."
    docker container prune -f 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Warning: Container pruning failed"
    fi

    log "Pruning unused images..."
    docker image prune -f 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Warning: Image pruning failed"
    fi

    log "Pruning unused networks..."
    docker network prune -f 2>&1 | tee -a "$LOG_FILE"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log "Warning: Network pruning failed"
    fi

    log "Docker resources pruning completed"
    return 0
}

# Function to display disk usage after cleanup
show_disk_usage() {
    log "Docker disk usage:"
    docker system df 2>&1 | tee -a "$LOG_FILE"
}

# Main execution
log "Starting HELIOS rebuild process..."

# Ensure external networks exist before rebuild
ensure_external_networks

# Rebuild all services
rebuild_docker_services

# Clean up any unused images, containers, and networks
prune_docker_system

# Show disk usage
show_disk_usage
