#!/bin/bash

# Source the environment variables
source /home/peter/Documents/dev/HELIOS/env.sh

# Define paths
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-metadata-refresh.log"
PLEX_CONFIG_DIR="${ROOT}/config/plexdb/Library/Application Support/Plex Media Server"
CONTAINER_NAME="plex"

# Function to log to file and console
log() {
    echo "$@" | tee -a "$LOG_FILE"
}

# Stop Plex Docker container
log "Stopping Plex Docker container..."
docker stop "$CONTAINER_NAME"
log "Plex Docker container stopped."

# Remove specific directories except for 'Playlists'
PLEX_METADATA_DIR="$PLEX_CONFIG_DIR/Metadata"
log "Removing metadata except for 'Playlists'..."
find "$PLEX_METADATA_DIR" -mindepth 1 -maxdepth 1 ! -name 'Playlists' -exec rm -rf {} \; 2>/dev/null
log "Metadata removal complete."

# Remove subdirectories of 'localhost' under 'Media'
PLEX_LOCALHOST_DIR="$PLEX_CONFIG_DIR/Media/localhost"
log "Removing subdirectories of 'localhost' under 'Media'..."
if [ -d "$PLEX_LOCALHOST_DIR" ]; then
    find "$PLEX_LOCALHOST_DIR" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \; 2>/dev/null
    log "Subdirectories removal complete."
else
    log "The 'localhost' directory does not exist or has already been removed."
fi

# Remove Cache directory
PLEX_CACHE_DIR="$PLEX_CONFIG_DIR/Cache"
log "Removing Cache directory..."
rm -rf "$PLEX_CACHE_DIR" 2>/dev/null
log "Cache directory removed."

# Restart Plex Docker container
log "Restarting Plex Docker container..."
docker restart "$CONTAINER_NAME"
log "Plex Docker container restarted. Metadata refresh will begin shortly."

# End of script
log "Script execution completed."
