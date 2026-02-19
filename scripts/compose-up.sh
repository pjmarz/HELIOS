#!/bin/bash
# ===========================================================================
# HELIOS COMPOSE UP SCRIPT
# ===========================================================================
# Starts all Docker Compose services in HELIOS system using the root
# docker-compose.yml
# ===========================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

# Function to run docker-compose up with the root file
run_docker_compose_up() {
    log "Starting all services using root docker-compose.yml..."
    cd "$HELIOS_ROOT" || { log "Error: Could not change to $HELIOS_ROOT"; exit 1; }

    # Run docker compose and capture output, preserving exit code
    docker compose up -d 2>&1 | tee -a "$LOG_FILE"
    local exit_code=${PIPESTATUS[0]}

    if [ $exit_code -eq 0 ]; then
        log "All services started successfully"
    else
        log "Error encountered while starting services (exit code: $exit_code)"
        exit $exit_code
    fi
}

# Run docker-compose up using the root compose file
run_docker_compose_up
