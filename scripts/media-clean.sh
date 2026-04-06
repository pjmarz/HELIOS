#!/bin/bash
# ===========================================================================
# HELIOS MEDIA CLEAN SCRIPT
# ===========================================================================
# Cleans Usenet download directories by removing contents of incomplete
# and completed folders.
# ===========================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

# Configuration (depends on DOWNLOADS_DIR from env.sh, sourced by _common.sh)
MEDIA_DEPLOYMENT="${HELIOS_ROOT}/deployments/media"
INCOMPLETE_DIR="${DOWNLOADS_DIR}/incomplete"
COMPLETE_DIR="${DOWNLOADS_DIR}/complete"

# Define specific folders to clean in the complete directory
FOLDERS=("movies" "tv" "default" "books")

# Validate paths to ensure they exist
if [[ ! -d "$HELIOS_ROOT" ]]; then
    log "Error: HELIOS root directory not found at $HELIOS_ROOT"
    exit 1
fi

if [[ ! -d "$MEDIA_DEPLOYMENT" ]]; then
    log "Error: Media deployment directory not found at $MEDIA_DEPLOYMENT"
    exit 1
fi

# Check if sabnzbd container exists and is running
log "Checking sabnzbd container status"
CONTAINER_RUNNING=$(docker ps --format '{{.Names}}' | grep -w "sabnzbd" || true)

if [[ -n "$CONTAINER_RUNNING" ]]; then
    # Container is running, need to stop and remove it
    log "Stopping and removing sabnzbd container"
    cd "$HELIOS_ROOT"
    docker compose stop sabnzbd || {
        log "Error: Failed to stop sabnzbd container"
        exit 1
    }
    docker compose rm -f sabnzbd || {
        log "Error: Failed to remove sabnzbd container"
        exit 1
    }
else
    log "sabnzbd container is not running"
fi

# Safeguard against accidental deletion
if [[ ! -d "$INCOMPLETE_DIR" || ! -d "$COMPLETE_DIR" ]]; then
    log "Error: One or more directories do not exist. Exiting to prevent accidental deletion."
    exit 1
fi

# Delete all contents of the incomplete directory
log "Deleting all contents of $INCOMPLETE_DIR"
if rm -rf "${INCOMPLETE_DIR:?}"/*; then
    log "Successfully cleared $INCOMPLETE_DIR"
else
    log "Error: Failed to clear $INCOMPLETE_DIR. Check permissions."
fi

# Loop through each folder in the completed directory and delete its contents
for folder in "${FOLDERS[@]}"; do
    TARGET_DIR="$COMPLETE_DIR/$folder"
    if [[ -d "$TARGET_DIR" ]]; then
        log "Deleting contents of $TARGET_DIR"
        if rm -rf "${TARGET_DIR:?}"/*; then
            log "Successfully cleared $TARGET_DIR"
        else
            log "Error: Failed to clear $TARGET_DIR. Check permissions."
        fi
    else
        log "Warning: Directory $TARGET_DIR does not exist. Skipping."
    fi
done

# Start the sabnzbd container
log "Starting sabnzbd container"
cd "$HELIOS_ROOT"
docker compose up -d sabnzbd || {
    log "Error: Failed to start sabnzbd container."
    exit 1
}

