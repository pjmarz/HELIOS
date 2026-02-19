#!/bin/bash
# ===========================================================================
# HELIOS COMPOSE REFRESH SCRIPT
# ===========================================================================
# Refreshes all Docker Compose services by stopping and starting them
# using the root docker-compose.yml
# ===========================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

log "Starting refresh of all services..."

log "--- Phase 1: Stopping services ---"
if "${SCRIPT_DIR}/compose-down.sh"; then
    log "Services stopped successfully"
else
    log "Error: compose-down.sh failed (exit code: $?)"
    exit 1
fi

log "--- Phase 2: Starting services ---"
if "${SCRIPT_DIR}/compose-up.sh"; then
    log "Services started successfully"
else
    log "Error: compose-up.sh failed (exit code: $?)"
    exit 1
fi

log "Successfully refreshed all Docker Compose services"
