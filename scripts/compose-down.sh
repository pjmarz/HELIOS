#!/bin/bash
# ===========================================================================
# HELIOS COMPOSE DOWN SCRIPT
# ===========================================================================
# Stops all Docker Compose services in HELIOS system using the root
# docker-compose.yml
# ===========================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

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
